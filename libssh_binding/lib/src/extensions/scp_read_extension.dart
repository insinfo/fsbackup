import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
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
    int bs = (4 * 1024);
    int bufferSize = remoteFileLength > bs ? bs : remoteFileLength;

    var nbytes = 0;
    final buffer = malloc<Int8>(bufferSize);
    var receive = '';
    //print('fileSize $fileSize');
    while (true) {
      var size = sizeOf<Int8>() * bufferSize;
      nbytes = ssh_scp_read(scp, buffer.cast(), size);
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

  Future<void> scpDownloadFileTo(ssh_session session, String fullPathSource, String fullPathTarget) async {
    var source = fullPathSource.toNativeUtf8();
    var scp = ssh_scp_new(session, SSH_SCP_READ, source.cast<Int8>());
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

    int bs = (4 * 1024);
    int bufferSize = remoteFileLength > bs ? bs : remoteFileLength;
    var nbytes = 0;
    final buffer = malloc<Int8>(bufferSize);

    var targetFile = await File(fullPathTarget).create(recursive: true);
    var sink = targetFile.openWrite(); // for appending at the end of file
    while (true) {
      var size = sizeOf<Int8>() * bufferSize;
      nbytes = ssh_scp_read(scp, buffer.cast(), size);
      //print('nbytes $nbytes');

      var data = buffer.asTypedList(nbytes);
      sink.add(data);

      if (nbytes < 0 || nbytes == SSH_ERROR || nbytes == remoteFileLength) {
        ssh_scp_close(scp);
        ssh_scp_free(scp);
        malloc.free(buffer);
        await sink.flush();
        await sink.close();
        break;
      }
    }

    if (nbytes != remoteFileLength) {
      throw Exception("Error Incomplete file");
    }
  }
}
