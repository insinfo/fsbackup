import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:fsbackup/models/backup_routine_model.dart';
import 'package:fsbackup/worker/worker.dart';
import 'package:libssh_binding/libssh_binding.dart';

//enum BackupStatus { Iniciando, Copiando, Completo, Cancelado }

class BackupTask implements FileTask<Future<bool>> {
  dio.CancelToken cancelToken;

  final BackupRoutineModel rotinaBackup;
  LibsshWrapper libssh;
  BackupTask(this.rotinaBackup, {this.taskId});
  @override
  Future<bool> execute() {
    return _doExecute();
  }

  Future<bool> _doExecute() async {
    final start = DateTime.now();
    cancelToken = dio.CancelToken();
    var completer = Completer<bool>();

    try {
      //var progress = ((loaded / total) * 100).round();
      var server = rotinaBackup.servers.first;
      libssh = LibsshWrapper(
        server.host,
        username: server.user,
        password: server.password,
        port: server.port,
        verbosity: false,
      );
      libssh.connect();

      var fileObjects = server.fileObjects;
      int totalSize = 0;
      int totalLoaded = 0;

      totalSize = fileObjects
          .map((d) => libssh.getSizeOfDirectory(d.path))
          .toList()
          .reduce((value, element) => value + element);

      print('dirretorios ${fileObjects.map((e) => e.path).toList().join(", ")} totalSize: $totalSize');

      for (var dir in fileObjects) {
        // var loadCurrent = 0;
        //faz o download do diretorio
        await libssh.scpDownloadDirectory(
          dir.path,
          rotinaBackup.destinationDirectory,
          printLog: (v) {
            tasklogCallback(v);
            print(v);
          },
          callbackStats: (int total, int loaded, int currentFileSize, int countDirectory, int countFiles) {
            totalLoaded += currentFileSize;
            taskProgressCallback(totalSize, totalLoaded, 'andamento');
          },
        );
        //totalLoaded += loadCurrent;
      }

      print('\r\n${DateTime.now().difference(start)}');

      libssh.dispose();

      completer.complete(true);
    } catch (e, s) {
      print('BackupTask error: $e $s');
      tasklogCallback('BackupTask error: $e $s');
      //completer.complete(true);
      completer.completeError(e);
    }

    return completer.future;
  }

  @override
  String taskId;

  @override
  ActionType actionType = ActionType.download;

  ///Function(int total, int loaded, String status);
  @override
  ProgressCallback taskProgressCallback;

  @override
  void handleCancel(String taskId) {}

  @override
  LogCallback tasklogCallback;
}
