enum FileObjectType { directory, file }

extension FileObjectTypeToString on FileObjectType {
  String get text {
    return this.toString().split('.').last;
  }
}

class FileSystemObject {
  FileSystemObject({this.path, this.fileObjectType});
  String path;
  FileObjectType fileObjectType;

  void fillFromMap(Map<String, dynamic> map) {
    path = map['path'];
    fileObjectType = map['fileObjectType'] == 'directory' ? FileObjectType.directory : FileObjectType.file;
  }

  factory FileSystemObject.fromMap(Map<String, dynamic> map) => FileSystemObject(
      path: map['path'],
      fileObjectType: map['fileObjectType'] == 'directory' ? FileObjectType.directory : FileObjectType.file);

  Map<String, dynamic> toMap() => {
        'path': path,
        'fileObjectType': fileObjectType == FileObjectType.directory ? 'directory' : 'file',
      };
}
