import 'dart:async';

import 'package:flutter/material.dart';
import 'package:libssh_binding/libssh_binding.dart';
import 'common.dart';
import 'filesystem_list.dart';

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

  static Future<DirectoryItem?> open({
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
    return Navigator.of(context).push<DirectoryItem>(
      MaterialPageRoute(builder: (BuildContext context) {
        return SftpFilePicker(
          onClose: onClose,
          rootName: rootName,
          fsType: fsType,
          pickText: pickText,
          title: title,
          folderIconColor: folderIconColor,
          allowedExtensions: allowedExtensions,
          onSelect: (DirectoryItem value) {
            Navigator.of(context).pop<DirectoryItem>(value);
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

  final LibsshWrapper? libsshWrapper;
  final LibssOptions? libssOptions;

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
  String? currentPath;
  TextEditingController urlCtr = TextEditingController();

  late DirectoryItem directory;
  @override
  void initState() {
    super.initState();
    currentPath = widget.rootDirectory;
    _setDirectory(DirectoryItem.fromDirPath(widget.rootDirectory));
  }

  void _setDirectory(DirectoryItem value) {
    directory = value;

    currentPath = directory.path; //directory.path;

    urlCtr.text = currentPath!;
  }

  void _changeDirectory(DirectoryItem value) {
    if (directory != value) {
      setState(() {
        _setDirectory(value);
      });
    }
    //print('_SftpFilePickerState@_changeDirectory ${value.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF2A2D3E),
        title: Text(widget.title ?? currentPath!),
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
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        if (currentPath != '/') {
                          var p = currentPath!.substring(0, currentPath!.lastIndexOf('/'));
                          p = p == '' ? '/' : p;
                          var dir = DirectoryItem.fromDirPath(p);
                          _changeDirectory(dir);
                        }
                      },
                      icon: Icon(Icons.arrow_back)),
                  Expanded(
                    child: TextFormField(
                      onFieldSubmitted: (value) {
                        _changeDirectory(DirectoryItem.fromDirPath(value));
                      },
                      controller: urlCtr,
                      decoration: InputDecoration(
                        isDense: true,
                        //labelText: 'Path:',
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 2.0),
                            borderRadius: BorderRadius.circular(25.0)),
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 2.0),
                            borderRadius: BorderRadius.circular(25.0)),
                      ),
                    ),
                  )
                ],
              )),
          /*Breadcrumbs<String>(
              items: pathItems
                  .map((path) => BreadcrumbItem<String>(text: path.text, data: path.path))
                  .toList(growable: false),
              onSelect: (String? value) {
                if (value != null) _changeDirectory(DirectoryItem.fromName(value));
              },
            ),*/

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
                      //widget.onSelect(currentSelectedPath);
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
