import 'dart:async';

import 'package:fsbackup_shared/fsbackup_shared.dart';
import 'package:libssh_binding/libssh_binding.dart';
import 'package:worker_isolated/worker_isolated.dart';

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

      final start = DateTime.now();
      for (var item in fileObjects) {
        if (item.type == DirectoryItemType.directory) {
          await libssh.scpDownloadDirectory(
            item.path,
            rotinaBackup.destinationDirectory,
            printLog: (v) {
              tasklogCallback(v);
            },
            callbackStats: (int total, int loaded, int currentFileSize,
                int countDirectory, int countFiles) {
              totalLoaded += currentFileSize;
              taskProgressCallback(totalSize, totalLoaded, 'a');
            },
          );
        } else if (item.type == DirectoryItemType.file) {
          var currentFileSize = 0;
          await libssh.scpDownloadFileTo(
            item.path,
            '${rotinaBackup.destinationDirectory}/${item.name}',
            callbackStats: (int total, int loaded) {
              currentFileSize = loaded;
            },
            recursive: false,
          );

          totalLoaded += currentFileSize;
          taskProgressCallback(totalSize, totalLoaded, 'a');
        }
        print('i');
      }

      tasklogCallback('${DateTime.now().difference(start)}');
      completer.complete(true);
    } catch (e, s) {
      tasklogCallback('BackupTask ${rotinaBackup.name} error: $e $s');
      completer.completeError(e);
    } finally {
      // completer.complete(true);
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
  void handleCancel(String taskId) {
    print('handleCancel');
  }

  @override
  LogCallback tasklogCallback;
}
