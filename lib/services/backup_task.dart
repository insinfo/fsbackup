import 'dart:async';
import 'dart:convert';
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
      final start = DateTime.now();
      //var progress = ((loaded / total) * 100).round();
      var server = rotinaBackup.servers.first;
      libssh = LibsshWrapper(
        server.host,
        username: server.user,
        password: server.password,
        port: server.port,
        verbosity: false,
      );
      addToLog('establishing SSH connection');
      libssh.connect();

      var now = DateFormat('yyyy.MM.dd.HH.mm.ss').format(DateTime.now());

      addToLog('create destination directory if not exist');

      if (rotinaBackup.compressAsZip == true) {
        destinationDirectory = await Utils.createDirectoryIfNotExist(
            '${rotinaBackup.destinationDirectory}\\tmp_${slugify(rotinaBackup.name, delimiter: "_")}_$now');
        zipFileName = '${rotinaBackup.destinationDirectory}\\${slugify(rotinaBackup.name, delimiter: "_")}_$now.zip';
      } else {
        destinationDirectory = await Utils.createDirectoryIfNotExist(
            '${rotinaBackup.destinationDirectory}\\${slugify(rotinaBackup.name, delimiter: "_")}');
      }

      List<DirectoryItem> fileObjects = server.fileObjects;
      int totalSize = 0;
      int totalLoaded = 0;
      addToLog('get total size of current backup task...');

      totalSize = fileObjects
          .map((d) => libssh.getSizeOfFileSystemItem(d))
          .toList()
          .reduce((value, element) => value + element);

      for (var item in fileObjects) {
        if (item.type == DirectoryItemType.directory) {
          await libssh.scpDownloadDirectory(
            item.path,
            destinationDirectory,
            printLog: (v) {
              addToLog(v);
            },
            callbackStats: (int total, int loaded, int currentFileSize, int countDirectory, int countFiles) {
              totalLoaded += currentFileSize;
              taskProgressCallback(totalSize, totalLoaded, 'copy');
            },
            cancelCallback: cancelCallback,
            updateStatsOnFileEnd: false,
            isThrowException: !rotinaBackup.dontStopIfFileException,
            dontStopIfFileException: rotinaBackup.dontStopIfFileException,
          );
        } else if (item.type == DirectoryItemType.file) {
          var currentFileSize = 0;
          final fullLocalPathFileName = '$destinationDirectory\\${item.name}';
          final localPathBytes = Utf8Encoder().convert(fullLocalPathFileName);

          print(
              'BackupTask download ${item.nativePathAsString} | ${item.name} | $fullLocalPathFileName | ${utf8.decode(localPathBytes, allowMalformed: true)}');
          //addToLog('BackupTask download  ${item.nativePathAsString} | ${item.name} | $fullPathFileName');

          await libssh.scpDownloadFileRaw(
            item.nativePath,
            localPathBytes,
            callbackStats: (int total, int loaded) {
              currentFileSize = loaded;
            },
            recursive: false,
            dontStopIfFileException: rotinaBackup.dontStopIfFileException,
          );

          totalLoaded += currentFileSize;
          taskProgressCallback(totalSize, totalLoaded, 'copy');
        }
      }

      addToLog('end of copy');
      addToLog('copy run time: ${DateTime.now().difference(start)}');

      if (rotinaBackup.compressAsZip == true) {
        final encoder = ZipFileEncoder();
        addToLog('start compress');
        taskProgressCallback(totalSize, 0, 'compress');
        final start2 = DateTime.now();
        // destinationDirectory
        encoder.zipDirectory(Directory(destinationDirectory), filename: zipFileName);
        addToLog('end compress');
        addToLog('compress run time: ${DateTime.now().difference(start2)}');
        taskProgressCallback(totalSize, totalSize, 'compress');
        /*try {
          addToLog('remove tmp directory');
          //await Directory(destinationDirectory).delete(recursive: true);
          // rmdir /s /q
          var r = await Process.run('rmdir', ['/s', '/q', destinationDirectory], runInShell: true);
          addToLog('del command stdout: ${r.stdout} ${r.stderr}');

          addToLog('tmp directory removed');
        } catch (e) {
          addToLog('error on remove tmp directory ($destinationDirectory) $e');
        }*/
      }

      if (rotinaBackup.removeOld == true) {
        try {
          addToLog('deleting old backups');
          var dias = rotinaBackup.holdOldFilesInDays;
          addToLog('hold Old Files In Days: $dias');
          final dir = Directory(rotinaBackup.destinationDirectory);
          final entities = await dir.list(recursive: false).toList();
          for (var entity in entities) {
            if (entity is File) {
              var lastModified = await entity.lastModified();
              if (DateTime.now().difference(lastModified).inDays > dias) {
                entity.deleteSync();
                addToLog('deleted ${entity.path}');
              }
            }
          }
        } catch (e) {
          addToLog('error on deleting old backups $e');
        }
      }
      addToLog('total backup run time: ${DateTime.now().difference(start)}');

      completer.complete(true);
    } catch (e, s) {
      addToLog('BackupTask ${rotinaBackup.name} error:\r\n$e\r\nStacktrace:\r\n$s');
      addToLog('remova o diretorio/arquivo temporario: zipFileName: $zipFileName | tmp dir: $destinationDirectory');
      //remove o arquivo imcompleto
      /*if (rotinaBackup.compressAsZip == true && zipFileName.isNotEmpty) {
        if (await File(zipFileName).exists()) {
          await File(zipFileName).delete();
          addToLog('remove $zipFileName');
        }
      }
      if (await Directory(destinationDirectory).exists()) {
        await Directory(destinationDirectory).delete(recursive: true);
        addToLog('remove $destinationDirectory');
      }*/

      print('BackupTask ${rotinaBackup.name} error:\r\n$e\r\nStacktrace:\r\n$s');
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

  void addToLog(String msg) {
    tasklogCallback('[${DateFormat("dd/MM/yyyy HH:mm:ss").format(DateTime.now())}] $msg');
  }

  @override
  CancelCallback cancelCallback;
}
