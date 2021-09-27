import 'package:libssh_binding/libssh_binding.dart';

/// Enumeration with options for display types of the file system.
enum FilesystemType {
  all,
  folder,
  file,
}

/// Value selection signature.
typedef ValueSelected = void Function(DirectoryItem value);

/// Mode for selecting files. Either only the button in the trailing
/// of ListTile, or onTap of the whole ListTile.
enum FileTileSelectMode {
  checkButton,
  wholeTile,
}
