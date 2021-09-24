import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:libssh_binding/libssh_binding.dart';
import 'common.dart';
import 'filesystem_list.dart';
import 'package:path/path.dart' as Path;
import 'breadcrumbs.dart';

class _PathItem {
  final String text;
  final String path;

  _PathItem({
    required this.path,
    required this.text,
  });

  @override
  String toString() {
    return '$text: $path';
  }
}

/// FileSystem file or folder picker dialog.
///
/// Allows the user to browse the file system and pick a folder or file.
///
/// See also:
///
///  * [SftpFilePicker.open]
class SftpFilePicker extends StatefulWidget {
  /// Open FileSystemPicker dialog
  ///
  /// Returns null if nothing was selected.
  ///
  /// * [rootName] specifies the name of the filesystem view root in breadcrumbs, by default "Storage".
  /// * [fsType] specifies the type of filesystem view (folder and files, folder only or files only), by default `FilesystemType.all`.
  /// * [pickText] specifies the text for the folder selection button (only for [fsType] = FilesystemType.folder).
  /// * [title] specifies the text of the dialog title.
  /// * [allowedExtensions] specifies a list of file extensions that will be displayed for selection, if empty - files with any extension are displayed. Example: `['.jpg', '.jpeg']`
  /// * [fileTileSelectMode] specifies how to files can be selected (either tapping on the whole tile or only on trailing button). (default depends on [fsType])

  static Future<String?> open({
    required BuildContext context,
    String rootName = 'Storage',
    FilesystemType fsType = FilesystemType.all,
    String? pickText,
    String? title,
    Color? folderIconColor,
    List<String>? allowedExtensions,
    FileTileSelectMode fileTileSelectMode = FileTileSelectMode.checkButton,
    void Function()? onClose,
    LibsshWrapper? libsshWrapper,
    LibssOptions? libssOptions,
  }) async {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (BuildContext context) {
        return SftpFilePicker(
          onClose: onClose,
          rootName: rootName,
          fsType: fsType,
          pickText: pickText,
          title: title,
          folderIconColor: folderIconColor,
          allowedExtensions: allowedExtensions,
          onSelect: (String value) {
            Navigator.of(context).pop<String>(value);
          },
          fileTileSelectMode: fileTileSelectMode,
          libsshWrapper: libsshWrapper,
          libssOptions: libssOptions,
        );
      }),
    );
  }

  // ---

  /// Specifies the name of the filesystem view root in breadcrumbs.
  final String? rootName;

  /// Specifies the type of filesystem view (folder and files, folder only or files only), by default `FilesystemType.all`.
  final FilesystemType fsType;

  /// Called when a file system item is selected.
  final ValueSelected onSelect;

  /// Specifies the text for the folder selection button (only for [fsType] = FilesystemType.folder).
  final String? pickText;

  /// Specifies the text of the dialog title.
  final String? title;

  /// Specifies the color of the icon for the folder.
  final Color? folderIconColor;

  /// Specifies a list of file extensions that will be displayed for selection, if empty - files with any extension are displayed. Example: `['.jpg', '.jpeg']`
  final List<String>? allowedExtensions;

  /// Specifies how to files can be selected (either tapping on the whole tile or only on trailing button). (default depends on [fsType])
  final FileTileSelectMode fileTileSelectMode;

  final void Function()? onClose;

  final String rootDirectory;

  LibsshWrapper? libsshWrapper;
  LibssOptions? libssOptions;

  /// Creates a file system item selection widget.
  SftpFilePicker({
    Key? key,
    this.rootName,
    this.rootDirectory = '/',
    this.fsType = FilesystemType.all,
    this.pickText,
    this.title,
    this.folderIconColor,
    this.allowedExtensions,
    required this.onSelect,
    required this.fileTileSelectMode,
    this.libsshWrapper,
    this.libssOptions,
    this.onClose,
  }) : super(key: key);

  @override
  _SftpFilePickerState createState() => _SftpFilePickerState();
}

class _SftpFilePickerState extends State<SftpFilePicker> {
  String currentSelectedPath = '';
  String? directoryName;
  late List<_PathItem> pathItems;

  late DirectoryItem directory;
  @override
  void initState() {
    super.initState();
    var dir = DirectoryItem.fromName(widget.rootDirectory);
    _setDirectory(dir);
  }

  void _setDirectory(DirectoryItem value) {
    directory = value;

    var pathSeparator = '/';

    pathItems = [];
    var countSeparator = directory.path.split(pathSeparator).length - 1;
    print('countSeparator $countSeparator ${directory.path}');

    if (countSeparator < 2) {
      pathItems.add(_PathItem(path: directory.path, text: directory.name));
    } else {
      final List<String> items = directory.path.split(pathSeparator);

      String path = widget.rootDirectory;

      for (var item in items) {
        path += item.startsWith(pathSeparator) ? item : item + pathSeparator;
        print(path);
        pathItems.add(_PathItem(path: path, text: item));
      }
    }

    directoryName = directory.path;
  }

  void _changeDirectory(DirectoryItem value) {
    if (directory != value) {
      setState(() {
        _setDirectory(value);
      });
    }
    print('_SftpFilePickerState@_changeDirectory ${value.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? directoryName!),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
            if (widget.onClose != null) {
              widget.onClose!();
            }
          },
        ),
        bottom: PreferredSize(
          child: Theme(
            data: ThemeData(
              textTheme: TextTheme(
                button: TextStyle(
                    color: AppBarTheme.of(context).toolbarTextStyle?.color ??
                        Theme.of(context).primaryTextTheme.headline6?.color),
              ),
            ),
            child: Breadcrumbs<String>(
              items: pathItems
                  .map((path) => BreadcrumbItem<String>(text: path.text, data: path.path))
                  .toList(growable: false),
              onSelect: (String? value) {
                if (value != null) _changeDirectory(DirectoryItem.fromName(value));
              },
            ),
          ),
          preferredSize: const Size.fromHeight(50),
        ),
      ),
      body: FilesystemList(
        isRoot: (directory.path == widget.rootDirectory),
        rootDirectory: directory,
        fsType: widget.fsType,
        folderIconColor: widget.folderIconColor,
        allowedExtensions: widget.allowedExtensions,
        onChange: _changeDirectory,
        onSelect: widget.onSelect,
        fileTileSelectMode: widget.fileTileSelectMode,
        libsshWrapper: widget.libsshWrapper,
        libssOptions: widget.libssOptions,
      ),
      bottomNavigationBar: (widget.fsType == FilesystemType.folder)
          ? Container(
              height: 50,
              child: BottomAppBar(
                color: Theme.of(context).primaryColor,
                child: Center(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      primary: AppBarTheme.of(context).titleTextStyle?.color ??
                          Theme.of(context).primaryTextTheme.headline6?.color,
                      onSurface: (AppBarTheme.of(context).titleTextStyle?.color ??
                              Theme.of(context).primaryTextTheme.headline6?.color)!
                          .withOpacity(0.5),
                    ),
                    icon: Icon(Icons.check_circle),
                    label: (widget.pickText != null) ? Text(widget.pickText!) : const SizedBox(),
                    onPressed: () {
                      widget.onSelect(currentSelectedPath);
                      if (widget.onClose != null) {
                        widget.onClose!();
                      }
                    },
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
