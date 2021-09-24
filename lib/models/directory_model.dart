import 'package:fsbackup/models/file_system_object.dart';

class DirectoryModel extends FileSystemObject {
  DirectoryModel({String path}) : super(path: path) {
    fileObjectType = FileObjectType.directory;
  }
}
