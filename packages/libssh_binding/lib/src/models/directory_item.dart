import 'dart:typed_data';

import 'package:libssh_binding/libssh_binding.dart';

enum DirectoryItemType { directory, file }

class DirectoryItem {
  late String name;
  int? size;
  late DirectoryItemType type;
  late String path;
  String? longname;

  ///Uint8Lost of  fullRemotePath
  List<int>? nativePath;

  DirectoryItem({
    required this.name,
    this.size,
    required this.type,
    required this.path,
    this.longname,
    this.nativePath,
  });

  factory DirectoryItem.fromPath(String strPath) {
    var separator = strPath.contains('/') ? '/' : '\\';
    var name = strPath.split(separator).length > 2 ? strPath.split(separator).last : strPath;

    var dir = DirectoryItem(
        name: name, path: strPath, nativePath: strPath.codeUnits, size: 0, type: DirectoryItemType.directory);

    return dir;
  }

  String get nativePathAsString {
    if (nativePath != null) {
      return uint8ListToString(Uint8List.fromList(nativePath!));
    }
    return '';
  }

  void fillFromMap(Map<String, dynamic> map) {
    name = map['name'];
    path = map['path'];
    type = map['type'] == 'directory' ? DirectoryItemType.directory : DirectoryItemType.file;
  }

  factory DirectoryItem.fromMap(Map<String, dynamic> map) => DirectoryItem(
      name: map['name'],
      path: map['path'],
      type: map['type'] == 'directory' ? DirectoryItemType.directory : DirectoryItemType.file);

  Map<String, dynamic> toMap() => {
        'name': name,
        'path': path,
        'type': type == DirectoryItemType.directory ? 'directory' : 'file',
      };

  @override
  String toString() {
    return '$name';
  }
}
