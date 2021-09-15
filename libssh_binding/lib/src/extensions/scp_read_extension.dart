import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:libssh_binding/src/constants.dart';
import 'package:libssh_binding/src/libssh.dart';

extension ScpReadExtension on Libssh {
  /// [fullPath] example => "helloworld/helloworld.txt"
  String scpReadFileAsString(ssh_session session, String fullPath) {
    var path = fullPath.toNativeUtf8();
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

    var nbytes = 0;
    final buffer = malloc<Int8>(bufferSize);
    var receive = '';
    //print('fileSize $fileSize');
    while (true) {
      nbytes = ssh_scp_read(scp, buffer.cast(), sizeOf<Int8>() * bufferSize);
      //print('nbytes $nbytes');

      var data = buffer.asTypedList(nbytes);
      receive += utf8.decode(data);

      if (nbytes < 0 || nbytes == SSH_ERROR || nbytes == remoteFileLength) {
        ssh_scp_close(scp);
        ssh_scp_free(scp);
        malloc.free(buffer);
        break;
      }
    }
    if (nbytes != remoteFileLength) {
      throw Exception("Error Incomplete file");
    }
    return receive;
  }

  Future<void> scpDownloadFileTo(ssh_session session, String fullRemotePathSource, String fullLocalPathTarget) async {
    var source = fullRemotePathSource.toNativeUtf8().cast<Int8>();
    var scp = ssh_scp_new(session, SSH_SCP_READ, source);
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

    var remoteFileLength = ssh_scp_request_get_size(scp);

    //var filename = ssh_scp_request_get_filename(scp).cast<Utf8>();
    //var mode = ssh_scp_request_get_permissions(scp);

    var nbytes = 0, nwritten = 0;
    var bufsize = 128 * 1024; //MAX_XFER_BUF_SIZE = 16384 = 16KB
    final buffer = calloc<Int8>(bufsize);

    if (buffer.address == nullptr.address) {
      print("Memory allocation error\n");
    }

    final stopwatch = Stopwatch()..start();
    var targetFile = await File(fullLocalPathTarget).create(recursive: true);
    var hFile = targetFile.openSync(mode: FileMode.write); // for appending at the end of file
    int len_loop = remoteFileLength;

    rc = ssh_scp_accept_request(scp);
    if (rc == SSH_ERROR) {
      throw Exception("Error ssh_scp_accept_request: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}");
    }

    do {
      nbytes = ssh_scp_read(scp, buffer.cast(), sizeOf<Int8>() * bufsize);
      nwritten += nbytes;

      if (nbytes == SSH_ERROR || nbytes < 0) {
        await hFile.close();
        ssh_scp_close(scp);
        ssh_scp_free(scp);
        calloc.free(buffer);
        throw Exception('Error receiving file data: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
      } else if (nbytes == 0) {
        break;
      }
      //print('nbytes $nbytes nwritten $nwritten');
      hFile.writeFromSync(buffer.asTypedList(nbytes));
      len_loop -= nbytes;
    } while (len_loop != 0);

    await hFile.close();
    calloc.free(buffer);
    var localFileLength = targetFile.lengthSync();

    print('remoteFileLength $remoteFileLength localFileLength $localFileLength');
    print("scpDownloadFileTo: ${stopwatch.elapsedMilliseconds} elapsed milliseconds ");

    if (localFileLength < nwritten) {
      ssh_scp_close(scp);
      ssh_scp_free(scp);
      malloc.free(buffer);
      throw Exception("Error Incomplete file");
    }

    ssh_scp_close(scp);
    ssh_scp_free(scp);
  }
}
