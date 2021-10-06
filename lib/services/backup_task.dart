import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:fsbackup/shared/utils/utils.dart';
import 'package:fsbackup_shared/fsbackup_shared.dart';
import 'package:intl/intl.dart';
import 'package:libssh_binding/libssh_binding.dart';
import 'package:slugify/slugify.dart';
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
    var destinationDirectory = '';
    var zipFileName = '';
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
      tasklogCallback('establishing SSH connection');
      libssh.connect();

      var now = DateFormat("yyyy_MM_dd_HH_mm_ss").format(DateTime.now());

      tasklogCallback('create destination directory if not exist');

      if (rotinaBackup.compressAsZip == true) {
        destinationDirectory = Utils.createDirectoryIfNotExist(
            '${rotinaBackup.destinationDirectory}/tmp_$now');
        zipFileName =
            '${rotinaBackup.destinationDirectory}/${slugify(rotinaBackup.name, delimiter: "_")}_$now.zip';
      } else {
        destinationDirectory = Utils.createDirectoryIfNotExist(
            '${rotinaBackup.destinationDirectory}/${slugify(rotinaBackup.name, delimiter: "_")}');
      }

      List<DirectoryItem> fileObjects = server.fileObjects;
      int totalSize = 0;
      int totalLoaded = 0;
      tasklogCallback('get total size of current backup task...');
      totalSize = fileObjects
          .map((d) => libssh.getSizeOfFileSystemItem(d))
          .toList()
          .reduce((value, element) => value + element);

      final start = DateTime.now();
      for (var item in fileObjects) {
        if (item.type == DirectoryItemType.directory) {
          await libssh.scpDownloadDirectory(
            item.path,
            destinationDirectory,
            printLog: (v) {
              tasklogCallback(v);
            },
            callbackStats: (int total, int loaded, int currentFileSize,
                int countDirectory, int countFiles) {
              totalLoaded += currentFileSize;
              taskProgressCallback(totalSize, totalLoaded, 'copy');
            },
            cancelCallback: cancelCallback,
          );
        } else if (item.type == DirectoryItemType.file) {
          var currentFileSize = 0;
          await libssh.scpDownloadFileTo(
            item.path,
            '$destinationDirectory/${item.name}',
            callbackStats: (int total, int loaded) {
              currentFileSize = loaded;
            },
            recursive: false,
          );

          totalLoaded += currentFileSize;
          taskProgressCallback(totalSize, totalLoaded, 'copy');
        }
      }

      tasklogCallback('end of copy');

      if (rotinaBackup.compressAsZip == true) {
        final encoder = ZipFileEncoder();
        tasklogCallback('start compress');
        taskProgressCallback(totalSize, 0, 'compress');

        encoder.zipDirectory(Directory(destinationDirectory),
            filename: zipFileName);

        tasklogCallback('end compress');
        taskProgressCallback(totalSize, totalSize, 'compress');
        tasklogCallback('remove tmp directory');
        await Directory(destinationDirectory).delete(recursive: true);
        tasklogCallback('tmp directory removed');
      }

      tasklogCallback(
          'total backup run time: ${DateTime.now().difference(start)}');
      completer.complete(true);
    } catch (e, s) {
      tasklogCallback('BackupTask ${rotinaBackup.name} error: $e ');
      //remove o arquivo imcompleto
      if (rotinaBackup.compressAsZip == true && zipFileName.isNotEmpty) {
        if (await File(zipFileName).exists()) {
          await File(zipFileName).delete();
        }
      }
      if (await Directory(destinationDirectory).exists()) {
        await Directory(destinationDirectory).delete(recursive: true);
      }

      //print('backupTask ${rotinaBackup.name} error: $e $s');
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

  bool isCanceled = false;

  @override
  void handleCancel(String taskId) {}

  @override
  LogCallback tasklogCallback;

  @override
  CancelCallback cancelCallback;
}
