import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:libssh_binding/src/constants.dart';
import 'package:libssh_binding/src/extensions/exec_command_extension.dart';
import 'package:libssh_binding/src/libssh_binding.dart';

extension ScpExtension on LibsshBinding {
  /// [fullPath] example => "helloworld/helloworld.txt"
  String scpReadFileAsString(ssh_session session, String fullPath, {Allocator allocator = malloc}) {
    var path = fullPath.toNativeUtf8(allocator: allocator);
    var scp = ssh_scp_new(session, SSH_SCP_READ, path.cast<Int8>());
    if (scp.address == nullptr.address) {
      throw Exception('Error allocating scp session: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }
    var rc = ssh_scp_init(scp);
    if (rc != SSH_OK) {
      ssh_scp_free(scp);
      throw Exception("Error initializing scp session: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}");
    }

    rc = ssh_scp_pull_request(scp);
    if (rc != ssh_scp_request_types.SSH_SCP_REQUEST_NEWFILE) {
      throw Exception(
          "Error receiving information about file: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}");
    }

    var remoteFileLength = ssh_scp_request_get_size64(scp);

    //var filename = ssh_scp_request_get_filename(scp).cast<Utf8>();
    //var mode = ssh_scp_request_get_permissions(scp);
    //var controller = StreamController<List<int>>();

    int bufferSize = MAX_XFER_BUF_SIZE; //remoteFileLength > bs ? bs : remoteFileLength;

    var nbytes = 0, nwritten = 0;
    final buffer = allocator<Int8>(bufferSize);
    var receive = '';

    while (true) {
      nbytes = ssh_scp_read(scp, buffer.cast(), sizeOf<Int8>() * bufferSize);
      nwritten += nbytes;

      var data = buffer.asTypedList(nbytes);
      receive += utf8.decode(data);

      if (nbytes < 0 || nbytes == SSH_ERROR) {
        ssh_scp_close(scp);
        ssh_scp_free(scp);
        allocator.free(buffer);
        break;
      }
    }
    allocator.free(path);
    if (nwritten < remoteFileLength) {
      throw Exception("Error Incomplete file");
    }
    return receive;
  }

  Pointer<ssh_scp_struct> initFileScp(ssh_session session, Pointer<Int8> remoteFilePath) {
    var scp = ssh_scp_new(session, SSH_SCP_READ, remoteFilePath);
    if (scp.address == nullptr.address) {
      throw Exception(
          'Error allocating scp file session: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }
    var rc = ssh_scp_init(scp);
    if (rc != SSH_OK) {
      ssh_scp_free(scp);
      throw Exception(
          "Error initializing scp file session: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}");
    }
    return scp;
  }

  Pointer<ssh_scp_struct> initDirectoryScp(ssh_session session, Pointer<Int8> remoteDirectoryPath) {
    var scp = ssh_scp_new(session, SSH_SCP_READ | SSH_SCP_RECURSIVE, remoteDirectoryPath);
    if (scp == nullptr) {
      throw Exception(
          'Error allocating scp directory session: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }
    var rc = ssh_scp_init(scp);
    if (rc != SSH_OK) {
      ssh_scp_free(scp);
      throw Exception(
          "Error initializing scp directory session: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}");
    }
    return scp;
  }

  Future<void> scpDownloadFileTo(ssh_session session, String fullRemotePathSource, String fullLocalPathTarget,
      {void Function(int total, int done)? callbackStats, Allocator allocator = malloc}) async {
    var source = fullRemotePathSource.toNativeUtf8(allocator: allocator).cast<Int8>();
    var scp = initFileScp(session, source);
    var rc = ssh_scp_pull_request(scp);
    if (rc != ssh_scp_request_types.SSH_SCP_REQUEST_NEWFILE) {
      ssh_scp_free(scp);
      throw Exception(
          "Error receiving information about file: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}");
    }

    rc = ssh_scp_accept_request(scp);
    if (rc == SSH_ERROR) {
      ssh_scp_close(scp);
      ssh_scp_free(scp);
      throw Exception("Error ssh_scp_accept_request: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}");
    }
    try {
      await scpReadFileAndSave(session, scp, fullLocalPathTarget, allocator: allocator, callbackStats: callbackStats);
    } catch (e) {
      rethrow;
    } finally {
      allocator.free(source);
      ssh_scp_close(scp);
      ssh_scp_free(scp);
    }
  }

  ///return total size in bytes of each file inside folder ignoring linux directory metadata size
  int getSizeOfDirectory(Pointer<ssh_session_struct> session, String remoteDirectoryPath,
      {bool isThrowException = true}) {
    //windows = 1041090242
    //ls -lAR | grep -v '^d' | awk '{total += $5} END {print "Total:", total}'
    //linux = 1041090469 -> find ./dart/  -type f -print | xargs -d '\n' du -bs | awk '{ sum+=$1} END {print sum}'
    try {
      var cmdToGetTotaSize =
          "find $remoteDirectoryPath -type f -print0 | xargs -0 stat --format=%s | awk '{s+=\$1} END {print s}'";
      var cmdRes = execCommandSync(session, cmdToGetTotaSize);
      return int.parse(cmdRes);
    } catch (e) {
      print('getSizeOfDirectory: $e');
      if (isThrowException) {
        throw Exception('Unable to get the size of a directory in bytes');
      }
    }
    return 0;
  }

  Future<void> scpReadFileAndSave(
      Pointer<ssh_session_struct> session, Pointer<ssh_scp_struct> scp, String fullLocalPathTarget,
      {void Function(int total, int done)? callbackStats, Allocator allocator = malloc}) async {
    var remoteFileLength = ssh_scp_request_get_size(scp);
    //var filename = ssh_scp_request_get_filename(scp).cast<Utf8>();
    //var mode = ssh_scp_request_get_permissions(scp);
    var targetFile = await File(fullLocalPathTarget).create(recursive: true);
    var hFile = targetFile.openSync(mode: FileMode.write); // for appending at the end of file
    int len_loop = remoteFileLength;
    var nbytes = 0, nwritten = 0;
    var bufsize = 128 * 1024; //MAX_XFER_BUF_SIZE = 16384 = 16KB
    final buffer = allocator<Int8>(bufsize);
    if (buffer.address == nullptr.address) {
      throw Exception("buffer Memory allocation error\n");
    }
    do {
      nbytes = ssh_scp_read(scp, buffer.cast(), sizeOf<Int8>() * bufsize);
      nwritten += nbytes;
      if (callbackStats != null) {
        callbackStats(remoteFileLength, nwritten);
      }
      if (nbytes == SSH_ERROR || nbytes < 0) {
        await hFile.close();
        allocator.free(buffer);
        throw Exception('Error receiving file data: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
      } else if (nbytes == 0) {
        break;
      }
      //print('nbytes $nbytes nwritten $nwritten');
      hFile.writeFromSync(buffer.asTypedList(nbytes));
      len_loop -= nbytes;
    } while (len_loop != 0);

    await hFile.close();
    allocator.free(buffer);
    var localFileLength = targetFile.lengthSync();
    if (localFileLength < nwritten) {
      throw Exception("Error Incomplete file");
    }
  }

  /// [fullLocalDirectoryPathTarget] example c:\downloads
  /// this function work only if remote is linux debian like sytem
  /// [callbackStats] function to show stattistcs callbackStats(totalSize, loaded, countDirectory, countFiles)
  Future<dynamic>? scpDownloadDirectory(
      Pointer<ssh_session_struct> session, String remoteDirectoryPath, String fullLocalDirectoryPathTarget,
      {Allocator allocator = malloc,
      void Function(int total, int loaded, int countDirectory, int countFiles)? callbackStats}) async {
    var source = remoteDirectoryPath.toNativeUtf8(allocator: allocator).cast<Int8>();

    String currentPath = '${fullLocalDirectoryPathTarget.replaceAll('\\', '/')}';
    String rootDirName = '';
    int currentDirSize = 0, totalSize = 0, loaded = 0, totalSizeFilesIgnorado = 0, countDirectory = 0, countFiles = 0;
    totalSize = getSizeOfDirectory(session, remoteDirectoryPath);
    print('totalSize: $totalSize');
    var scp = initDirectoryScp(session, source);

    String currentDirName = '';
    var rc = 0;
    bool isFirstDirectory = true;
    bool exitLoop = false;
    do {
      rc = ssh_scp_pull_request(scp);
      if (exitLoop) {
        break;
      }

      switch (rc) {
        //Um novo arquivo será obtido
        case ssh_scp_request_types.SSH_SCP_REQUEST_NEWFILE:
          var filename = ssh_scp_request_get_filename(scp).cast<Utf8>().toDartString();
          var fileSize = ssh_scp_request_get_size64(scp);
          // print("file: $filename size: $fileSize");
          ssh_scp_accept_request(scp);
          await scpReadFileAndSave(session, scp, '$currentPath/$filename');
          countFiles++;
          loaded += fileSize;
          //var progress = ((loaded / totalSize) * 100).round();
          //print('\r totalSize: $totalSize | loaded: $loaded | $progress %');
          //stdout.write('\r');
          //stdout.write('\r[${List.filled(((progress / 10) * 4).round(), '=').join()}] $progress%');
          if (callbackStats != null) {
            //(int total, int loaded, int countDirectory, int countFiles)
            callbackStats(totalSize, loaded, countDirectory, countFiles);
          }
          break;
        case SSH_ERROR:
          totalSizeFilesIgnorado += ssh_scp_request_get_size64(scp);
          print('Error: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
          exitLoop = true;
          break;
        case ssh_scp_request_types.SSH_SCP_REQUEST_WARNING:
          print('Warning: ${ssh_scp_request_get_warning(scp).cast<Utf8>().toDartString()}');
          break;
        //Um novo diretório será puxado
        case ssh_scp_request_types.SSH_SCP_REQUEST_NEWDIR:
          currentDirName = ssh_scp_request_get_filename(scp).cast<Utf8>().toDartString();
          //currentDirSize = ssh_scp_request_get_size64(scp);
          //var mode = ssh_scp_request_get_permissions(scp);
          currentPath += '/$currentDirName';
          if (isFirstDirectory == true) {
            rootDirName = '/$currentDirName';
            isFirstDirectory = false;
          }
          Directory('$currentPath').createSync(recursive: true);
          countDirectory++;
          //print("directory: $currentDirName | currentPath: $currentPath");
          ssh_scp_accept_request(scp);
          break;
        //End of directory
        case ssh_scp_request_types.SSH_SCP_REQUEST_ENDDIR:
          var parts = currentPath.split('/');
          parts.removeLast();
          currentPath = parts.join('/');
          //print("End of directory ");
          break;
        case ssh_scp_request_types.SSH_SCP_REQUEST_EOF:
          print("End of requests");
          exitLoop = true;
          break;
        default:
          break;
      }
    } while (true);
    print('TotalSize: $totalSize | loaded: $loaded ');
    allocator.free(source);
    ssh_scp_close(scp);
    ssh_scp_free(scp);
    return null;
  }
}