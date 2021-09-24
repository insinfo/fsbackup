import 'package:fsbackup/models/file_system_object.dart';

class FileModel extends FileSystemObject {
  FileModel({String path}) : super(path: path) {
    fileObjectType = FileObjectType.file;
  }
}
