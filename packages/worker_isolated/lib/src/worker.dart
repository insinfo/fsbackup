library worker.core;

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:stack_trace/stack_trace.dart';

import 'events.dart';

part 'worker_impl.dart';
part 'worker_isolate_src.dart';

/// A concurrent [Task] executor.
///
/// A [Worker] creates and manages a pool of isolates providing you with an easy
/// way to perform blocking tasks concurrently.
/// It spawns isolates lazily as [Task]s
/// are required to execute.

abstract class Worker {
  bool get isClosed;

  /// Size of the pool of isolates.
  int poolSize;

  /// All spawned isolates
  Queue<WorkerIsolate> get isolates;

  /// Spawned isolates that are free to handle more tasks.
  Iterable<WorkerIsolate> get availableIsolates;

  /// Isolates that are currently performing a task.
  Iterable<WorkerIsolate> get workingIsolates;

  /// Stream of isolate spawned events.
  Stream<IsolateSpawnedEvent> get onIsolateSpawned;

  /// Stream of isolate closed events.
  Stream<IsolateClosedEvent> get onIsolateClosed;

  /// Stream of task scheduled events.
  Stream<TaskScheduledEvent> get onTaskScheduled;

  /// Stream of task completed events.
  Stream<TaskCompletedEvent> get onTaskCompleted;

  /// Stream of task failed events.
  Stream<TaskFailedEvent> get onTaskFailed;

  factory Worker({int poolSize, bool spawnLazily = true}) {
    poolSize ??= Platform.numberOfProcessors;

    return _WorkerImpl(poolSize: poolSize, spawnLazily: spawnLazily);
  }

  /// Returns a [Future] with the result of the execution of the [Task].
  Future handle(Task task,
      {Function(TransferProgress progress) progressCallback,
      void Function(TaskLog taskLog) logCallback});

  /// Closes the [ReceivePort] of the isolates.
  /// Waits until all scheduled tasks have completed if [afterDone] is `true`.
  Future<Worker> close({bool afterDone});

  Future<dynamic> cancel();
}

/// A representation of an isolate
///
/// A representation of an isolate containing a [SendPort] to it and the tasks
/// that are running on it.
abstract class WorkerIsolate {
  bool get isClosed;
  bool get isFree;
  Task get runningTask;
  List<Task> get scheduledTasks;
  String taskId;

  /// Stream of task spawned events.
  Stream<IsolateSpawnedEvent> get onSpawned;

  /// Stream of task closed events.
  Stream<IsolateClosedEvent> get onClosed;

  /// Stream of task scheduled events.
  Stream<TaskScheduledEvent> get onTaskScheduled;

  /// Stream of task completed events.
  Stream<TaskCompletedEvent> get onTaskCompleted;

  /// Stream of task failed events.
  Stream<TaskFailedEvent> get onTaskFailed;

  factory WorkerIsolate() => _WorkerIsolateImpl();

  Future performTask(Task task,
      {Function(TransferProgress progress) progressCallback,
      void Function(TaskLog taskLog) logCallback});

  /// Closes the [ReceivePort] of the isolate.
  /// Waits until all scheduled tasks have completed if [afterDone] is `true`.
  Future<WorkerIsolate> close({bool afterDone});

  ReceivePort getReceivePort();
  SendPort getSendPort();

  Future<dynamic> cancel();
}

class TaskCancelledException implements Exception {
  final Task task;

  TaskCancelledException(this.task);

  @override
  String toString() => '$task cancelled.';
}

/// A task that needs to be executed.
///
/// This class provides an interface for tasks.
abstract class Task<T> {
  T execute();
}

/// void Function(int total , int loaded, String status);
typedef ProgressCallback = void Function(int total, int loaded, String status);

typedef LogCallback = void Function(String log);

typedef CancelCallback = bool Function();

abstract class FileTask<T> extends Task<T> {
  ProgressCallback taskProgressCallback;
  LogCallback tasklogCallback;
  CancelCallback cancelCallback;
  String taskId;
  ActionType actionType;

  void handleCancel(String taskId);
}

enum ActionType { upload, download, cancelUpload, cancelDownload }

//enum CallbackType { pregress, log }

class TransferProgress {
  final int loaded;
  final int total;
  final String status;

  const TransferProgress({this.total, this.loaded, this.status});
}

class TaskLog {
  final String log;

  const TaskLog({this.log});
}
