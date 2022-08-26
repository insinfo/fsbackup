import 'dart:convert';
import 'dart:typed_data';

import 'package:libssh_binding/libssh_binding.dart';

/*

attr->type = SSH_FILEXFER_TYPE_SPECIAL;
          break;
        case SSH_S_IFLNK:
          attr->type = SSH_FILEXFER_TYPE_SYMLINK;
          break;
        case SSH_S_IFREG:
          attr->type = SSH_FILEXFER_TYPE_REGULAR;
          break;
        case SSH_S_IFDIR:
          attr->type = SSH_FILEXFER_TYPE_DIRECTORY;
          break;
        default:
          attr->type = SSH_FILEXFER_TYPE_UNKNOWN;
           */
enum DirectoryItemType { directory, file }

extension DirectoryItemTypeExtension on DirectoryItemType {
  String get text {
    return this.toString().split('.').last;
  }
}

class DirectoryItem {
  late String name;
  int? size;
  late DirectoryItemType type;
  late String path;
  String? longname;
  bool isSymbolicLink = false;
  bool isRegularFile = false;
  bool isDirectory = true;
  bool isSpecialFile = false;
  bool isUnknownFile = false;
  int? flags = 0;
  int? atime = 0;
  int? mtime = 0;
  int? createtime = 0;

  /// quando é link começã com L Ex: lrwxrwxrwx, quando é diretorio começa com d Ex: drwxr-xr-x
  int? permissions = 0;

  ///Uint8List of  fullRemotePath
  Uint8List? nativePath;

  DirectoryItem({
    required this.name,
    this.size,
    required this.type,
    required this.path,
    this.longname,
    this.nativePath,
    this.flags = 0,
    this.atime = 0,
    this.mtime = 0,
    this.createtime = 0,
    this.permissions = 0,
    this.isSymbolicLink = false,
    this.isRegularFile = false,
    this.isDirectory = false,
    this.isSpecialFile = false,
    this.isUnknownFile = false,
  });

  /// create regular directory instance of DirectoryItem ( isDirectory: true)
  factory DirectoryItem.fromDirPath(String strPath) {
    var separator = strPath.contains('/') ? '/' : '\\';
    var name = strPath.split(separator).length > 2 ? strPath.split(separator).last : strPath;

    var dir = DirectoryItem(
        name: name,
        path: strPath,
        nativePath: Utf8Encoder().convert(strPath),
        size: 0,
        type: DirectoryItemType.directory,
        isDirectory: true,
        isSymbolicLink: false);

    return dir;
  }

  /// create regular file instance of DirectoryItem (isRegularFile: true)
  factory DirectoryItem.fromFilePath(String strPath) {
    var separator = strPath.contains('/') ? '/' : '\\';
    var name = strPath.split(separator).length > 2 ? strPath.split(separator).last : strPath;

    var dir = DirectoryItem(
        name: name,
        path: strPath,
        nativePath: Utf8Encoder().convert(strPath),
        size: 0,
        type: DirectoryItemType.file,
        isDirectory: false,
        isRegularFile: true,
        isSymbolicLink: false);

    return dir;
  }

  String get nativePathAsString {
    if (nativePath != null) {
      return uint8ListToString(nativePath!);
    }
    return '';
  }

  void fillFromMap(Map<String, dynamic> map) {
    name = map['name'];
    path = map['path'];
    type = map['type'] == 'directory' ? DirectoryItemType.directory : DirectoryItemType.file;
    if (map.containsKey('nativePath') && map['nativePath'] is List) {
      nativePath = Uint8List.fromList((map['nativePath'] as List).map<int>((e) => e as int).toList());
    }
    longname = map['longname'];
    size = map['size'];

    flags = map['flags'];
    atime = map['atime'];
    mtime = map['mtime'];
    createtime = map['createtime'];
    permissions = map['permissions'];

    isSymbolicLink = map['isSymbolicLink'];
    isRegularFile = map['isRegularFile'];
    isDirectory = map['isDirectory'];
    isSpecialFile = map['isSpecialFile'];
    isUnknownFile = map['isUnknownFile'];
  }

  factory DirectoryItem.fromMap(Map<String, dynamic> map) {
    final dir = DirectoryItem(name: '', path: '', type: DirectoryItemType.file);
    dir.fillFromMap(map);
    return dir;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'name': name,
      'path': path,
      'type': type == DirectoryItemType.directory ? 'directory' : 'file',
    };

    map['nativePath'] = nativePath;

    map['longname'] = longname;
    map['size'] = size;

    map['flags'] = flags;
    map['atime'] = atime;
    map['mtime'] = mtime;
    map['createtime'] = createtime;
    map['permissions'] = permissions;

    map['isSymbolicLink'] = isSymbolicLink;
    map['isRegularFile'] = isRegularFile;
    map['isDirectory'] = isDirectory;
    map['isSpecialFile'] = isSpecialFile;
    map['isUnknownFile'] = isUnknownFile;
    return map;
  }

  @override
  String toString() {
    return '$name';
  }
}
