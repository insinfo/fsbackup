import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:libssh_binding/src/fcntl.dart';
import 'package:libssh_binding/src/libssh.dart';
import 'package:libssh_binding/src/sftp.dart';
import 'package:libssh_binding/src/stat.dart';

import '../constants.dart';

import 'dart:developer';

extension SftpExtension on Libssh {
  /// create Directory on the remote computer
  /// [fullPath] example => "/home/helloworld"
  void sftpCreateDirectory(ssh_session session, String fullPath) {
    var path = fullPath.toNativeUtf8();
    var sftp = sftp_new(session);
    if (sftp.address == nullptr.address) {
      throw Exception('Error allocating SFTP session: ${sftp_get_error(sftp)}');
    }

    var rc = sftp_init(sftp);
    if (rc != SSH_OK) {
      sftp_free(sftp);
      throw Exception('Error initializing SFTP session: ${sftp_get_error(sftp)}');
    }

    rc = sftp_mkdir(sftp, path.cast(), S_IRWXU);
    if (rc != SSH_OK) {
      if (sftp_get_error(sftp) != SSH_FX_FILE_ALREADY_EXISTS) {
        throw Exception('Can\'t create directory: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
      }
    }

    sftp_free(sftp);
  }

  /// Copying a local file to the remote computer
  Future<void> sftpCopyLocalFileToRemote(
      ssh_session session, String localFilefullPath, String remoteFilefullPath) async {
    var remotePath = remoteFilefullPath.toNativeUtf8();
    var sftp = initSftp(session);
    //get remote file for writing
    int access_type = O_WRONLY | O_CREAT | O_TRUNC;
    var remoteFile = sftp_open(sftp, remotePath.cast(), access_type, S_IRWXU);
    if (remoteFile.address == nullptr.address) {
      sftp_free(sftp);
      throw Exception(
          'Can\'t open remote file for writing: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }

    //get local file
    var localFile = File(localFilefullPath);

    if (localFile.existsSync() == false) {
      sftp_free(sftp);
      throw Exception('Local File don\'t exists');
    }

    var localFileLength = localFile.lengthSync();

    var lfile = await localFile.open(mode: FileMode.read);
    int bs = MAX_XFER_BUF_SIZE; //(4 * 1024);
    int bufferSize = localFileLength > bs ? bs : localFileLength;

    final bufferNative = malloc<Uint8>(bufferSize);
    var nwritten = 0;
    //var builder = new BytesBuilder(copy: false);
    while (true) {
      var bufferDart = await lfile.read(bufferSize);

      //builder.add(bufferDart);
      if (bufferDart.length <= 0) {
        break;
      }

      bufferNative.asTypedList(bufferSize).setAll(0, bufferDart);
      nwritten += sftp_write(remoteFile, bufferNative.cast(), sizeOf<Int8>() * bufferSize);
    }
    await lfile.close();
    malloc.free(bufferNative);
    print('localFileLength: $localFileLength | nwritten: $nwritten');
    //print('localFile:  ${utf8.decode(builder.takeBytes())}');

    if (nwritten < localFileLength) {
      sftp_close(remoteFile);
      sftp_free(sftp);
      throw Exception(
          'Can\'t write data to file, incomplete file: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }

    var rc = sftp_close(remoteFile);
    if (rc != SSH_OK) {
      sftp_free(sftp);
      throw Exception('Can\'t close the written file: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }

    sftp_free(sftp);
  }

  Future<void> sftpDownloadFileTo(ssh_session session, String fullRemotePath, String fullLocalPath,
      {Pointer<sftp_session_struct>? inSftp}) async {
    var remotePath = fullRemotePath.toNativeUtf8();

    var sftp = inSftp != null ? inSftp : initSftp(session);

    var access_type = O_RDONLY;

    var remoteFile = sftp_open(sftp, remotePath.cast(), access_type, 0);
    if (remoteFile.address == nullptr.address) {
      sftp_free(sftp);
      throw Exception('Can\'t open file for reading: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }
    var nbytes = 0, nwritten = 0;
    var bufferSize = MAX_XFER_BUF_SIZE * 2; //MAX_XFER_BUF_SIZE = 16384 = 16KB
    final bufferNative = malloc<Uint8>(bufferSize);

    var targetFile = await File(fullLocalPath).create(recursive: true);
    var sink = targetFile.openWrite(); // for appending at the end of file
    var bfs = sizeOf<Int8>() * bufferSize;
    var bfn = bufferNative.cast<Void>();

    Timeline.startSync('sftpDownloadFileTo');
    final stopwatch = Stopwatch()..start();
    var start = DateTime.now();
    while (true) {
      nbytes = sftp_read(remoteFile, bfn, bfs);
      nwritten += nbytes;
      if (nbytes == 0) {
        break; // EOF
      } else if (nbytes < 0) {
        await sink.flush();
        await sink.close();
        sftp_close(remoteFile);
        if (inSftp == null) {
          sftp_free(sftp);
        }
        malloc.free(bufferNative);
        throw Exception('Error while reading file: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
      }

      sink.add(bufferNative.asTypedList(nbytes));
    }
    stopwatch.stop();
    print(DateTime.now().difference(start));
    print("sftpDownloadFileTo: ${stopwatch.elapsedMilliseconds} elapsed milliseconds");
    Timeline.finishSync();

    await sink.flush();
    await sink.close();

    var localFileLength = targetFile.lengthSync();

    if (localFileLength < nwritten) {
      sftp_close(remoteFile);
      if (inSftp == null) {
        sftp_free(sftp);
      }
      malloc.free(bufferNative);
      throw Exception('Incomplete file: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }

    var rc = sftp_close(remoteFile);
    if (rc != SSH_OK) {
      if (inSftp == null) {
        sftp_free(sftp);
      }
      malloc.free(bufferNative);
      throw Exception('Can\'t close the written file: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }

    if (inSftp == null) {
      sftp_free(sftp);
    }
    malloc.free(bufferNative);
  }
}
