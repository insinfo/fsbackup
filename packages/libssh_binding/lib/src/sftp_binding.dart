// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'dart:ffi' as ffi;
import 'libssh_binding.dart';

/// Bindings to sftp

class sftp_attributes_struct extends ffi.Struct {
  external ffi.Pointer<ffi.Int8> name;

  external ffi.Pointer<ffi.Int8> longname;

  @ffi.Uint32()
  external int flags;

  @ffi.Uint8()
  external int type;

  @ffi.Uint64()
  external int size;

  @ffi.Uint32()
  external int uid;

  @ffi.Uint32()
  external int gid;

  external ffi.Pointer<ffi.Int8> owner;

  external ffi.Pointer<ffi.Int8> group;

  @ffi.Uint32()
  external int permissions;

  @ffi.Uint64()
  external int atime64;

  @ffi.Uint32()
  external int atime;

  @ffi.Uint32()
  external int atime_nseconds;

  @ffi.Uint64()
  external int createtime;

  @ffi.Uint32()
  external int createtime_nseconds;

  @ffi.Uint64()
  external int mtime64;

  @ffi.Uint32()
  external int mtime;

  @ffi.Uint32()
  external int mtime_nseconds;

  external ssh_string acl;

  @ffi.Uint32()
  external int extended_count;

  external ssh_string extended_type;

  external ssh_string extended_data;
}

class sftp_client_message_struct extends ffi.Struct {
  external sftp_session sftp;

  @ffi.Uint8()
  external int type;

  @ffi.Uint32()
  external int id;

  external ffi.Pointer<ffi.Int8> filename;

  @ffi.Uint32()
  external int flags;

  external sftp_attributes attr;

  external ssh_string handle;

  @ffi.Uint64()
  external int offset;

  @ffi.Uint32()
  external int len;

  @ffi.Int32()
  external int attr_num;

  external ssh_buffer attrbuf;

  external ssh_string data;

  external ssh_buffer complete_message;

  external ffi.Pointer<ffi.Int8> str_data;

  external ffi.Pointer<ffi.Int8> submessage;
}

typedef sftp_session = ffi.Pointer<sftp_session_struct>;

class sftp_session_struct extends ffi.Struct {
  external ssh_session session;

  external ssh_channel channel;

  @ffi.Int32()
  external int server_version;

  @ffi.Int32()
  external int client_version;

  @ffi.Int32()
  external int version;

  external sftp_request_queue queue;

  @ffi.Uint32()
  external int id_counter;

  @ffi.Int32()
  external int errnum;

  external ffi.Pointer<ffi.Pointer<ffi.Void>> handles;

  external sftp_ext ext;

  external sftp_packet read_packet;
}

typedef sftp_request_queue = ffi.Pointer<sftp_request_queue_struct>;

class sftp_request_queue_struct extends ffi.Struct {
  external sftp_request_queue1 next;

  external sftp_message message;
}

typedef sftp_request_queue1 = ffi.Pointer<sftp_request_queue_struct>;
typedef sftp_message = ffi.Pointer<sftp_message_struct>;

class sftp_message_struct extends ffi.Struct {
  external sftp_session1 sftp;

  @ffi.Uint8()
  external int packet_type;

  external ssh_buffer payload;

  @ffi.Uint32()
  external int id;
}

typedef sftp_session1 = ffi.Pointer<sftp_session_struct>;

typedef sftp_ext = ffi.Pointer<sftp_ext_struct>;

class sftp_ext_struct extends ffi.Opaque {}

typedef sftp_packet = ffi.Pointer<sftp_packet_struct>;

class sftp_packet_struct extends ffi.Struct {
  external sftp_session1 sftp;

  @ffi.Uint8()
  external int type;

  external ssh_buffer payload;
}

typedef sftp_attributes = ffi.Pointer<sftp_attributes_struct>;

class sftp_dir_struct extends ffi.Struct {
  external sftp_session sftp;

  external ffi.Pointer<ffi.Int8> name;

  external ssh_string handle;

  external ssh_buffer buffer;

  @ffi.Uint32()
  external int count;

  @ffi.Int32()
  external int eof;
}

class sftp_file_struct extends ffi.Struct {
  external sftp_session sftp;

  external ffi.Pointer<ffi.Int8> name;

  @ffi.Uint64()
  external int offset;

  external ssh_string handle;

  @ffi.Int32()
  external int eof;

  @ffi.Int32()
  external int nonblocking;
}

class sftp_status_message_struct extends ffi.Struct {
  @ffi.Uint32()
  external int id;

  @ffi.Uint32()
  external int status;

  external ssh_string error_unused;

  external ssh_string lang_unused;

  external ffi.Pointer<ffi.Int8> errormsg;

  external ffi.Pointer<ffi.Int8> langmsg;
}

/// @brief SFTP statvfs structure.
class sftp_statvfs_struct extends ffi.Struct {
  @ffi.Uint64()
  external int f_bsize;

  /// file system block size
  @ffi.Uint64()
  external int f_frsize;

  /// fundamental fs block size
  @ffi.Uint64()
  external int f_blocks;

  /// number of blocks (unit f_frsize)
  @ffi.Uint64()
  external int f_bfree;

  /// free blocks in file system
  @ffi.Uint64()
  external int f_bavail;

  /// free blocks for non-root
  @ffi.Uint64()
  external int f_files;

  /// total file inodes
  @ffi.Uint64()
  external int f_ffree;

  /// free file inodes
  @ffi.Uint64()
  external int f_favail;

  /// free file inodes for to non-root
  @ffi.Uint64()
  external int f_fsid;

  /// file system id
  @ffi.Uint64()
  external int f_flag;

  /// bit mask of f_flag values
  @ffi.Uint64()
  external int f_namemax;
}

typedef sftp_dir = ffi.Pointer<sftp_dir_struct>;
typedef sftp_file = ffi.Pointer<sftp_file_struct>;

typedef ssize_t = SSIZE_T;
typedef SSIZE_T = LONG_PTR;
typedef LONG_PTR = ffi.Int64;

typedef uid_t = ffi.Uint32;
typedef gid_t = ffi.Uint32;

typedef sftp_statvfs_t = ffi.Pointer<sftp_statvfs_struct>;
typedef sftp_client_message = ffi.Pointer<sftp_client_message_struct>;

const int LIBSFTP_VERSION = 3;

const int SSH_FXP_INIT = 1;

const int SSH_FXP_VERSION = 2;

const int SSH_FXP_OPEN = 3;

const int SSH_FXP_CLOSE = 4;

const int SSH_FXP_READ = 5;

const int SSH_FXP_WRITE = 6;

const int SSH_FXP_LSTAT = 7;

const int SSH_FXP_FSTAT = 8;

const int SSH_FXP_SETSTAT = 9;

const int SSH_FXP_FSETSTAT = 10;

const int SSH_FXP_OPENDIR = 11;

const int SSH_FXP_READDIR = 12;

const int SSH_FXP_REMOVE = 13;

const int SSH_FXP_MKDIR = 14;

const int SSH_FXP_RMDIR = 15;

const int SSH_FXP_REALPATH = 16;

const int SSH_FXP_STAT = 17;

const int SSH_FXP_RENAME = 18;

const int SSH_FXP_READLINK = 19;

const int SSH_FXP_SYMLINK = 20;

const int SSH_FXP_STATUS = 101;

const int SSH_FXP_HANDLE = 102;

const int SSH_FXP_DATA = 103;

const int SSH_FXP_NAME = 104;

const int SSH_FXP_ATTRS = 105;

const int SSH_FXP_EXTENDED = 200;

const int SSH_FXP_EXTENDED_REPLY = 201;

const int SSH_FILEXFER_ATTR_SIZE = 1;

const int SSH_FILEXFER_ATTR_PERMISSIONS = 4;

const int SSH_FILEXFER_ATTR_ACCESSTIME = 8;

const int SSH_FILEXFER_ATTR_ACMODTIME = 8;

const int SSH_FILEXFER_ATTR_CREATETIME = 16;

const int SSH_FILEXFER_ATTR_MODIFYTIME = 32;

const int SSH_FILEXFER_ATTR_ACL = 64;

const int SSH_FILEXFER_ATTR_OWNERGROUP = 128;

const int SSH_FILEXFER_ATTR_SUBSECOND_TIMES = 256;

const int SSH_FILEXFER_ATTR_EXTENDED = 2147483648;

const int SSH_FILEXFER_ATTR_UIDGID = 2;

const int SSH_FILEXFER_TYPE_REGULAR = 1;

const int SSH_FILEXFER_TYPE_DIRECTORY = 2;

const int SSH_FILEXFER_TYPE_SYMLINK = 3;

const int SSH_FILEXFER_TYPE_SPECIAL = 4;

const int SSH_FILEXFER_TYPE_UNKNOWN = 5;

const int SSH_FX_OK = 0;

const int SSH_FX_EOF = 1;

const int SSH_FX_NO_SUCH_FILE = 2;

const int SSH_FX_PERMISSION_DENIED = 3;

const int SSH_FX_FAILURE = 4;

const int SSH_FX_BAD_MESSAGE = 5;

const int SSH_FX_NO_CONNECTION = 6;

const int SSH_FX_CONNECTION_LOST = 7;

const int SSH_FX_OP_UNSUPPORTED = 8;

const int SSH_FX_INVALID_HANDLE = 9;

const int SSH_FX_NO_SUCH_PATH = 10;

const int SSH_FX_FILE_ALREADY_EXISTS = 11;

const int SSH_FX_WRITE_PROTECT = 12;

const int SSH_FX_NO_MEDIA = 13;

const int SSH_FXF_READ = 1;

const int SSH_FXF_WRITE = 2;

const int SSH_FXF_APPEND = 4;

const int SSH_FXF_CREAT = 8;

const int SSH_FXF_TRUNC = 16;

const int SSH_FXF_EXCL = 32;

const int SSH_FXF_TEXT = 64;

const int SSH_S_IFMT = 61440;

const int SSH_S_IFSOCK = 49152;

const int SSH_S_IFLNK = 40960;

const int SSH_S_IFREG = 32768;

const int SSH_S_IFBLK = 24576;

const int SSH_S_IFDIR = 16384;

const int SSH_S_IFCHR = 8192;

const int SSH_S_IFIFO = 4096;

const int SSH_FXF_RENAME_OVERWRITE = 1;

const int SSH_FXF_RENAME_ATOMIC = 2;

const int SSH_FXF_RENAME_NATIVE = 4;

const int SFTP_OPEN = 3;

const int SFTP_CLOSE = 4;

const int SFTP_READ = 5;

const int SFTP_WRITE = 6;

const int SFTP_LSTAT = 7;

const int SFTP_FSTAT = 8;

const int SFTP_SETSTAT = 9;

const int SFTP_FSETSTAT = 10;

const int SFTP_OPENDIR = 11;

const int SFTP_READDIR = 12;

const int SFTP_REMOVE = 13;

const int SFTP_MKDIR = 14;

const int SFTP_RMDIR = 15;

const int SFTP_REALPATH = 16;

const int SFTP_STAT = 17;

const int SFTP_RENAME = 18;

const int SFTP_READLINK = 19;

const int SFTP_SYMLINK = 20;

const int SFTP_EXTENDED = 200;

const int SSH_FXE_STATVFS_ST_RDONLY = 1;

const int SSH_FXE_STATVFS_ST_NOSUID = 2;
