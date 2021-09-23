// ignore_for_file: close_sinks

part of worker.core;

class _WorkerImpl implements Worker {
  bool _isClosed = false;

  @override
  bool get isClosed => _isClosed;

  @override
  int poolSize;

  @override
  final Queue<WorkerIsolate> isolates = Queue<WorkerIsolate>();

  @override
  Iterable<WorkerIsolate> get availableIsolates => isolates.where((isolate) => isolate.isFree);

  @override
  Iterable<WorkerIsolate> get workingIsolates => isolates.where((isolate) => !isolate.isFree);

  final StreamController<IsolateSpawnedEvent> _isolateSpawnedEventController =
      StreamController<IsolateSpawnedEvent>.broadcast();

  @override
  Stream<IsolateSpawnedEvent> get onIsolateSpawned => _isolateSpawnedEventController.stream;

  final StreamController<IsolateClosedEvent> _isolateClosedEventController =
      StreamController<IsolateClosedEvent>.broadcast();

  @override
  Stream<IsolateClosedEvent> get onIsolateClosed => _isolateClosedEventController.stream;

  final StreamController<TaskScheduledEvent> _taskScheduledEventController =
      StreamController<TaskScheduledEvent>.broadcast();

  @override
  Stream<TaskScheduledEvent> get onTaskScheduled => _taskScheduledEventController.stream;

  final StreamController<TaskCompletedEvent> _taskCompletedEventController =
      StreamController<TaskCompletedEvent>.broadcast();

  @override
  Stream<TaskCompletedEvent> get onTaskCompleted => _taskCompletedEventController.stream;

  final StreamController<TaskFailedEvent> _taskFailedEventController = StreamController<TaskFailedEvent>.broadcast();

  @override
  Stream<TaskFailedEvent> get onTaskFailed => _taskFailedEventController.stream;

  _WorkerImpl({this.poolSize = 1, bool spawnLazily = true}) {
    if (poolSize <= 0) {
      poolSize = 1;
    }

    if (!spawnLazily) {
      for (var i = 0; i < poolSize; i++) {
        _spawnIsolate();
      }
    }
  }

//  Future handle (Task task) {
//    if (this.isClosed)
//      throw new Exception('Worker is closed!');
//
//    WorkerIsolate isolate = this._selectIsolate();
//
//    if (isolate != null)
//      return isolate.performTask(task);
//    else
//      throw new Exception("No isolate available");
//  }

  @override
  Future handle(Task task,
      {Function(TransferProgress progress) progressCallback, void Function(TaskLog taskLog) logCallback}) {
    if (isClosed) throw Exception('Worker is closed!');

    if (task is FileTask &&
        (task.actionType == ActionType.cancelUpload || task.actionType == ActionType.cancelDownload)) {
      var taskId = task.taskId;
      for (var workerIsolate in workingIsolates) {
        //  print('Worker: handle: CancelFileTask: $workerIsolate');
        if (workerIsolate.taskId == taskId) {
          workerIsolate.performTask(task, progressCallback: progressCallback, logCallback: logCallback);
        }
      }

      return Future<dynamic>.value(null);
    }

    var isolate = _selectIsolate();

    if (isolate != null) {
      return isolate.performTask(task, progressCallback: progressCallback, logCallback: logCallback);
    } else {
      throw Exception('No isolate available');
    }
  }

  WorkerIsolate _selectIsolate() {
    return isolates.firstWhere((islt) => islt.isFree, orElse: () {
      WorkerIsolate isolate;

      if (isolates.length < poolSize) {
        isolate = _spawnIsolate();
      } else {
        isolate = isolates.firstWhere((isolate) => isolate.isFree,
            orElse: () => isolates.reduce((a, b) => a.scheduledTasks.length <= b.scheduledTasks.length ? a : b));
      }

      return isolate;
    });
  }

  WorkerIsolate _spawnIsolate() {
    var isolate = _WorkerIsolateImpl();
    mergeStream(_isolateSpawnedEventController, isolate.onSpawned);
    mergeStream(_isolateClosedEventController, isolate.onClosed);
    mergeStream(_taskScheduledEventController, isolate.onTaskScheduled);
    mergeStream(_taskCompletedEventController, isolate.onTaskCompleted);
    mergeStream(_taskFailedEventController, isolate.onTaskFailed);
    isolates.add(isolate);

    return isolate;
  }

  @override
  Future<Worker> close({bool afterDone = true}) {
    if (_isClosed) {
      return Future.value(this);
    }

    _isClosed = true;

    var closeFutures = <Future<WorkerIsolate>>[];

    for (var isolate in isolates) {
      closeFutures.add(isolate.close(afterDone: afterDone));
    }
    //_isolateSpawnedEventController?.close();
    return Future.wait(closeFutures).then((_) => this);
  }
}

class _WorkerIsolateImpl implements WorkerIsolate {
  Map<String, Function(TransferProgress progress)> mapTaskProgressCallback = {};
  Map<String, Function(TaskLog taskLog)> mapTaskLogCallback = {};
  bool _isClosed = false;

  @override
  bool get isClosed => _isClosed;

  ReceivePort _receivePort;

  SendPort _sendPort;

  final Queue<_ScheduledTask> _scheduledTasks = Queue<_ScheduledTask>();

  _ScheduledTask _runningScheduledTask;

  @override
  Task get runningTask => _runningScheduledTask != null ? _runningScheduledTask.task : null;

  @override
  List<Task> get scheduledTasks => _scheduledTasks.map((scheduledTask) => scheduledTask.task).toList(growable: false);

  @override
  bool get isFree => _scheduledTasks.isEmpty && _runningScheduledTask == null;

  final StreamController<IsolateSpawnedEvent> _spawnEventController = StreamController<IsolateSpawnedEvent>.broadcast();

  @override
  Stream<IsolateSpawnedEvent> get onSpawned => _spawnEventController.stream;

  final StreamController<IsolateClosedEvent> _closeEventController = StreamController<IsolateClosedEvent>.broadcast();

  @override
  Stream<IsolateClosedEvent> get onClosed => _closeEventController.stream;

  final StreamController<TaskScheduledEvent> _taskScheduledEventController =
      StreamController<TaskScheduledEvent>.broadcast();

  @override
  Stream<TaskScheduledEvent> get onTaskScheduled => _taskScheduledEventController.stream;

  final StreamController<TaskCompletedEvent> _taskCompletedEventController =
      StreamController<TaskCompletedEvent>.broadcast();

  @override
  Stream<TaskCompletedEvent> get onTaskCompleted => _taskCompletedEventController.stream;

  final StreamController<TaskFailedEvent> _taskFailedEventController = StreamController<TaskFailedEvent>.broadcast();

  @override
  Stream<TaskFailedEvent> get onTaskFailed => _taskFailedEventController.stream;

  Completer<WorkerIsolate> _closeCompleter;

  _WorkerIsolateImpl() {
    _receivePort = ReceivePort();

    _spawnIsolate();
  }

  Future<WorkerIsolate> _spawnIsolate() {
    var completer = Completer<WorkerIsolate>();
    Isolate.spawn(_workerMain, _receivePort.sendPort).then((isolate) {}, onError: (e) {
      //print(e);
    });

    _receivePort.listen((dynamic message) {
//      print('Worker: receivePort: $message');
      if (message is _WorkerLog) {
        Function callbackLog = mapTaskLogCallback[message.taskId];
        if (callbackLog != null) {
          callbackLog(TaskLog(log: message.log));
        } else {
//          print('... but not callback for taskId=${message.taskId}');
        }
        return;
      } else if (message is _WorkerProgress) {
        Function callbackProgress = mapTaskProgressCallback[message.taskId];
        if (callbackProgress != null) {
          callbackProgress(TransferProgress(
            loaded: message.loaded,
            total: message.total,
            status: message.status,
          ));
        } else {
//          print('... but not callback for taskId=${message.taskId}');
        }
        return;
      } else if (message is FileTask &&
          (message.actionType == ActionType.cancelUpload || message.actionType == ActionType.cancelDownload)) {
        //print('... CancelFileTask this=$this');

        return;
      } else if (message is SendPort) {
        // print('... SendPort this=$this');
        completer.complete(this);
        _spawnEventController.add(IsolateSpawnedEvent(this));
        _sendPort = message;

        _runNextTask();

        return;
      } else if (message is String) {
        //print('... SendPort this String=$message');
//        completer.complete(this);
//        this._spawnEventController.add(new IsolateSpawnedEvent(this));
        taskId = message;

//        this._runNextTask();

        return;
      } else if (message is _WorkerException) {
        _taskFailedEventController
            .add(TaskFailedEvent(this, _runningScheduledTask.task, message.exception, message.stackTrace));
        _runningScheduledTask.completer.completeError(message.exception, message.stackTrace);
      } else if (message is _WorkerSignal) {
        if (message.id == closeSignal.id) {
          _closeEventController.add(IsolateClosedEvent(this));
          _closeStreamControllers();
          _receivePort.close();
        }
      } else if (message is _WorkerResult) {
        print('... WorkerResult result=${message.result}, this=$this');
        _taskCompletedEventController.add(TaskCompletedEvent(this, _runningScheduledTask.task, message.result));

        _runningScheduledTask.completer.complete(message.result);
      }

      _runningScheduledTask = null;

      _runNextTask();
    }, onError: (dynamic exception) {
      _runningScheduledTask.completer.completeError(exception);
      _runningScheduledTask = null;
    });

    return completer.future;
  }

  @override
  Future performTask(Task task,
      {Function(TransferProgress progress) progressCallback, void Function(TaskLog taskLog) logCallback}) {
    // print('Worker: performTask $task');
    if (isClosed) throw StateError('This WorkerIsolate is closed.');

    if (task is FileTask &&
        (task.actionType == ActionType.cancelUpload || task.actionType == ActionType.cancelDownload)) {
      //  print('Worker: performTask _sendPort.send of CancelFileTask');
      _sendPort.send(task);
      return Future<void>.value(null);
    }

    var completer = Completer<void>();

    if (task is FileTask && (task.actionType == ActionType.upload || task.actionType == ActionType.download)) {
      mapTaskProgressCallback[task.taskId] = progressCallback;
      mapTaskLogCallback[task.taskId] = logCallback;
    }

    _scheduledTasks.add(_ScheduledTask(task, completer));
    _taskScheduledEventController.add(TaskScheduledEvent(this, task));

    _runNextTask();

    return completer.future;
  }

  void _runNextTask() {
    if (_sendPort == null ||
        _scheduledTasks.isEmpty ||
        (_runningScheduledTask != null && !_runningScheduledTask.completer.isCompleted)) {
      return;
    }

    _runningScheduledTask = _scheduledTasks.removeFirst();

    _sendPort.send(_runningScheduledTask.task);
  }

  void _closeStreamControllers() {
    _spawnEventController.close();
    _closeEventController.close();
    _taskScheduledEventController.close();
    _taskCompletedEventController.close();
    _taskFailedEventController.close();
  }

  @override
  Future<WorkerIsolate> close({bool afterDone = true}) {
    if (_isClosed) {
      return Future.value(this);
    }

    _isClosed = true;
    _closeCompleter = Completer<WorkerIsolate>();

    if (afterDone) {
      var closeIfDone = (dynamic data) {
        if (isFree) {
          _close();
        }
      };

      var waitTasksToComplete = () {
        if (!isFree) {
          onTaskCompleted.listen(closeIfDone);
          onTaskFailed.listen(closeIfDone);
        } else {
          _close();
        }
      };

      if (_sendPort == null) {
        onSpawned.listen((_) {
          waitTasksToComplete();
        });
      } else {
        waitTasksToComplete();
      }
    } else {
      onSpawned.first.then((_) {
        _close();
      });
    }

    return _closeCompleter.future;
  }

  void _close() {
    if (_sendPort != null) {
      _sendPort.send(closeSignal);
      _sendPort = null;
    }

    _receivePort.close();
    _closeEventController.add(IsolateClosedEvent(this));
    _closeCompleter.complete(this);

    var cancelTask = (_ScheduledTask scheduledTask) {
      var exception = TaskCancelledException(scheduledTask.task);
      scheduledTask.completer.completeError(exception);

      _taskFailedEventController.add(TaskFailedEvent(this, scheduledTask.task, exception));
    };

    if (_runningScheduledTask != null) {
      cancelTask(_runningScheduledTask);
    }

    _scheduledTasks.forEach(cancelTask);
  }

  @override
  String taskId;
}

class _ScheduledTask {
  Completer completer;
  Task task;

  _ScheduledTask(this.task, this.completer);
}

/// Signals:
///  1 - CloseIsolate
const closeSignal = _WorkerSignal(1);

class _WorkerSignal {
  final int id;

  const _WorkerSignal(this.id);
}

class _WorkerResult {
  final dynamic result;
  final String taskId;
  _WorkerResult(this.result, {this.taskId});

  @override
  String toString() {
    return '_WorkerResult{result=$result, taskId=$taskId}';
  }
}

class _WorkerException {
  final dynamic exception;
  final List<Frame> stackTraceFrames;
  StackTrace get stackTrace {
    if (stackTraceFrames != null) {}

    return null;
  }

  _WorkerException(this.exception, this.stackTraceFrames);
}

void mergeStream(EventSink sink, Stream stream) {
  stream.listen((dynamic data) => sink.add(data),
      onError: (dynamic errorEvent, StackTrace stackTrace) => sink.addError(errorEvent, stackTrace));
}

// An add code
class _WorkerProgress {
  int loaded;
  int total;
  String status;

  String taskId;

  _WorkerProgress({this.loaded, this.total, this.taskId, this.status});

  @override
  String toString() {
    return '_WorkerProgress{loaded=$loaded, total=$total}, status=$status';
  }
}

class _WorkerLog {
  String log;

  String taskId;

  _WorkerLog({this.taskId, this.log});

  @override
  String toString() {
    return '_WorkerLog{taskId=$taskId, log=$log}';
  }
}
