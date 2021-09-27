import 'dart:async';

import 'package:fsbackup/models/backup_routine_model.dart';

import 'package:fsbackup/worker/worker.dart';
import 'package:libssh_binding/libssh_binding.dart';

//enum BackupStatus { Iniciando, Copiando, Completo, Cancelado }

class BackupTask implements FileTask<Future<bool>> {
  final BackupRoutineModel rotinaBackup;
  LibsshWrapper libssh;
  BackupTask(this.rotinaBackup, {this.taskId});
  @override
  Future<bool> execute() {
    return _doExecute();
  }

  Future<bool> _doExecute() async {
    final start = DateTime.now();

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

      List<DirectoryItem> fileObjects = server.fileObjects;
      int totalSize = 0;
      int totalLoaded = 0;

      totalSize = fileObjects
          .map((d) => libssh.getSizeOfFileSystemItem(d))
          .toList()
          .reduce((value, element) => value + element);

      print('dirretorios ${fileObjects.map((e) => e.path).toList().join(", ")} totalSize: $totalSize');

      for (var item in fileObjects) {
        if (item.type == DirectoryItemType.directory) {
          //faz o download do diretorio
          print('faz backup dir');
          await libssh.scpDownloadDirectory(
            item.path,
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
        } else if (item.type == DirectoryItemType.file) {
          print('faz backup file');
          await libssh.scpDownloadFileTo(item.path, '${rotinaBackup.destinationDirectory}/${item.name}',
              recursive: false);
        }
      }

      print('\r\n${DateTime.now().difference(start)}');
    } catch (e, s) {
      print('BackupTask error: $e $s');
      tasklogCallback('BackupTask error: $e $s');
      //completer.complete(true);
      //completer.completeError(e);
    } finally {
      completer.complete(true);
      libssh.dispose();
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
