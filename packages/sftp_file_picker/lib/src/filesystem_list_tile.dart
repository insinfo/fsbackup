import 'package:flutter/material.dart';
import 'package:libssh_binding/libssh_binding.dart';
import 'common.dart';
import 'package:path/path.dart' as Path;

class FilesystemListTile extends StatelessWidget {
  static double iconSize = 32;

  final FilesystemType fsType;
  final DirectoryItem item;
  final Color? folderIconColor;
  final ValueChanged<DirectoryItem> onChange;
  final ValueSelected onSelect;
  final FileTileSelectMode fileTileSelectMode;

  FilesystemListTile({
    Key? key,
    this.fsType = FilesystemType.all,
    required this.item,
    this.folderIconColor,
    required this.onChange,
    required this.onSelect,
    required this.fileTileSelectMode,
  }) : super(key: key);

  Widget _leading(BuildContext context) {
    if (item.type == DirectoryItemType.directory) {
      return Icon(
        item.isSymbolicLink == true ? Icons.drive_file_move : Icons.folder,
        color: folderIconColor ?? Theme.of(context).unselectedWidgetColor,
        size: iconSize,
      );
    } else {
      return _fileIcon(item.path, Theme.of(context).unselectedWidgetColor);
    }
  }

  /// Set the icon for a file
  Icon _fileIcon(String filename, Color color) {
    var icon = Icons.description;
    if (filename.contains('.')) {
      final _extension = filename.split(".").last;
      if (_extension == "db" ||
          _extension == "sqlite" ||
          _extension == "sqlite3") {
        icon = Icons.dns;
      } else if (_extension == "jpg" ||
          _extension == "jpeg" ||
          _extension == "png") {
        icon = Icons.image;
      }
    }
    if (item.isSymbolicLink == true) {
      icon = Icons.upload_file;
    }
    // default
    return Icon(
      icon,
      color: color,
      size: iconSize,
    );
  }

  Widget? _trailing(BuildContext context) {
    if ((fsType == FilesystemType.all) ||
        ((fsType == FilesystemType.file) &&
            (item.type == DirectoryItemType.file) &&
            (fileTileSelectMode != FileTileSelectMode.wholeTile))) {
      return InkResponse(
        child: Icon(
          Icons.check_circle,
          color: Theme.of(context).disabledColor,
        ),
        onTap: () => onSelect(item),
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        key: Key(item.path),
        leading: _leading(context),
        trailing: _trailing(context),
        title: Text(Path.basename(item.path), textScaleFactor: 1.2),
        onTap: (item.type == DirectoryItemType.directory)
            ? () => onChange(item)
            : ((fsType == FilesystemType.file &&
                    fileTileSelectMode == FileTileSelectMode.wholeTile)
                ? () => onSelect(item)
                : null));
  }
}
