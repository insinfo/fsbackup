import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:libssh_binding/src/extensions/base_extension.dart';
import 'package:libssh_binding/src/fcntl.dart';
import 'package:libssh_binding/src/libssh_binding.dart';
import 'package:libssh_binding/src/models/directory_item.dart';
import 'package:libssh_binding/src/sftp_binding.dart';
import 'package:libssh_binding/src/stat.dart';
import '../constants.dart';

extension SftpExtension on LibsshBinding {
  /// create Directory on the remote computer
  /// [fullPath] example => "/home/helloworld"
  void sftpCreateDirectory(ssh_session session, String fullRemotePath, {Allocator allocator = malloc}) {
    final path = fullRemotePath.toNativeUtf8();
    final sftp = initSftp(session);

    var rc = sftp_mkdir(sftp, path.cast(), S_IRWXU);
    if (rc != SSH_OK) {
      if (sftp_get_error(sftp) != SSH_FX_FILE_ALREADY_EXISTS) {
        throw Exception('Can\'t create directory: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
      }
    }
    allocator.free(path);
    sftp_free(sftp);
  }

  /// Listing the contents of a directory
  List<DirectoryItem> sftpListDir(ssh_session session, String fullRemotePath, {Allocator allocator = malloc}) {
    final sftp = initSftp(session);
    final results = <DirectoryItem>[];
    final path = fullRemotePath.toNativeUtf8(allocator: allocator);
    var dir = sftp_opendir(sftp, path.cast());
    if (dir == nullptr) {
      sftp_free(sftp);
      throw Exception('Directory not opened: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }
    //print("Name                       Size Perms    Owner\tGroup\n");
    sftp_attributes attributes;

    while ((attributes = sftp_readdir(sftp, dir)) != nullptr) {
      if (sftp_dir_eof(dir) == 1) {
        break;
      }
      //longname => drwxrwxrwx    2 www-data www-data     4096 Jun 25  2018 .ssh
      var name = attributes.ref.name.cast<Utf8>().toDartString();
      /* print(
          '$name  | ${attributes.ref.size} | ${attributes.ref.permissions} | ${attributes.ref.owner.cast<Utf8>().toDartString()} |' +
              '${attributes.ref.uid} |  ${attributes.ref.group.cast<Utf8>().toDartString()}  ${attributes.ref.gid}');
        */
      //var t = attributes.ref.type == 1 ? 'file' : 'directory';
      results.add(DirectoryItem(
          name: name,
          type: attributes.ref.type == 1 ? DirectoryItemType.file : DirectoryItemType.directory,
          size: attributes.ref.size));

      sftp_attributes_free(attributes);
    }

    /*if (sftp_dir_eof(dir) == 1) {
      sftp_closedir(dir);
      sftp_free(sftp);
      throw Exception('Can\'t list directory: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }*/

    var rc = sftp_closedir(dir);
    if (rc != SSH_OK) {
      sftp_free(sftp);
      throw Exception('Can\'t close directory: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }
    allocator.free(path);
    sftp_free(sftp);

    return results;
  }

  /// Copying a local file to the remote computer
  Future<void> sftpCopyLocalFileToRemote(ssh_session session, String localFilefullPath, String remoteFilefullPath,
      {Allocator allocator = malloc}) async {
    var remotePath = remoteFilefullPath.toNativeUtf8(allocator: allocator);
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

    final bufferNative = allocator<Uint8>(bufferSize);
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
    allocator.free(bufferNative);
    allocator.free(remoteFile);
    // print('localFileLength: $localFileLength | nwritten: $nwritten');
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

    sftp_close(remoteFile);
    sftp_free(sftp);
  }

  Future<void> sftpDownloadFileTo(ssh_session session, String fullRemotePath, String fullLocalPath,
      {void Function(int total, int done)? callbackStats,
      Pointer<sftp_session_struct>? inSftp,
      Allocator allocator = malloc}) async {
    var ftpfile = fullRemotePath.toNativeUtf8().cast<Int8>();

    var sftp = inSftp != null ? inSftp : initSftp(session);

    //int res = 0;
    int totalReceived = 0;
    int totalSize = -1;
    int retcode = 0;
    var bufsize = 128 * 1024; //MAX_XFER_BUF_SIZE = 16384 = 16KB
    //Pointer<Uint32> len = nullptr; //lpNumberOfBytesWritten

    var sfile = sftp_open(sftp, ftpfile, O_RDONLY, 0664);
    if (sfile.address == nullptr.address) {
      sftp_free(sftp);
      throw Exception('Can\'t open file for reading: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }

    var fattr = sftp_stat(sftp, ftpfile);
    if (fattr.address == nullptr.address) {
      totalSize = -1;
    } else {
      totalSize = fattr.ref.size;
      sftp_attributes_free(fattr);
    }

    /*var hFile = CreateFile(
        fullLocalPath.toNativeUtf16(), // name of the write
        GENERIC_READ | GENERIC_WRITE, // open for writing
        0, // do not share
        nullptr, // default security
        CREATE_ALWAYS, // create new file only
        FILE_ATTRIBUTE_NORMAL, // normal file
        0);
    if (hFile == INVALID_HANDLE_VALUE) {
      throw Exception('Unable to open local file $ftpfile for write.');
    }*/

    var localFile = File(fullLocalPath);
    var hFile = localFile.openSync(mode: FileMode.write);

    final buf = allocator<Int8>(bufsize);
    do {
      retcode = sftp_read(sfile, buf.cast<Void>(), bufsize);

      /*res = WriteFile(hFile, buf, retcode, len, nullptr);
      if (res == FALSE) {
        print("Terminal failure: Unable to write to file.\n");
        break;
      }*/
      totalReceived += retcode;
      if (callbackStats != null) {
        callbackStats(totalSize, totalReceived);
      }

      //print('retcode: $retcode data: ${data.length}');
      hFile.writeFromSync(buf.asTypedList(retcode));
      //retcode = sftp_read(sfile, buf.cast<Void>(), bufsize);

    } while (retcode > 0);
    //await hFile.flush();
    await hFile.close();

    var localFileLength = localFile.lengthSync();
    if (localFileLength < totalReceived) {
      sftp_close(sfile);
      if (inSftp == null) {
        sftp_free(sftp);
      }
      allocator.free(buf);
      throw Exception('Incomplete file: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }

    var rc = sftp_close(sfile);
    if (rc != SSH_OK) {
      if (inSftp == null) {
        sftp_free(sftp);
      }
      allocator.free(buf);
      throw Exception('Can\'t close the written file: ${ssh_get_error(session.cast()).cast<Utf8>().toDartString()}');
    }

    if (inSftp == null) {
      sftp_free(sftp);
    }
    allocator.free(buf);
  }
}
