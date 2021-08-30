import 'dart:async';

import 'package:dartssh/client.dart';
import 'package:dio/dio.dart' as dio;
import 'package:fsbackup/models/rotina_backup.dart';

import 'package:fsbackup/worker/worker.dart';

//enum BackupStatus { Iniciando, Copiando, Completo, Cancelado }

class BackupTask implements FileTask<Future<bool>> {
  dio.CancelToken cancelToken;
  String status = 'aguardando';
  final RotinaBackup rotinaBackup;

  BackupTask(this.rotinaBackup, {this.taskId});

  @override
  Future<bool> execute() {
    return _doExecute();
  }

  SSHClient client;
  Future<bool> _doExecute() async {
    cancelToken = dio.CancelToken();
    var completer = Completer<bool>();

    try {
      status = 'inicio';
      taskProgressCallback(1, 0, status);

      await Future.delayed(Duration(seconds: 30));
      taskProgressCallback(1, 1, 'fim');
      completer.complete(true);
    } catch (e, s) {
      status = 'error';
      //taskProgressCallback(1, 1, 'error');
      print('BackupTask error: $e $s');
      completer.complete(true);
      //completer.completeError(e);
    }

    return completer.future;
  }

  @override
  String taskId;

  @override
  ActionType actionType = ActionType.download;

  @override
  ProgressCallback taskProgressCallback;

  @override
  void handleCancel(String taskId) {}
}
