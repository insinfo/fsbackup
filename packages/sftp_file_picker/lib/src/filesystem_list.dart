import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:libssh_binding/libssh_binding.dart';
import 'package:path/path.dart' as Path;
import 'common.dart';
import 'filesystem_list_tile.dart';

class FilesystemList extends StatelessWidget {
  final bool isRoot;
  final FilesystemType fsType;
  final Color? folderIconColor;
  final List<String>? allowedExtensions;
  final ValueChanged<DirectoryItem> onChange;
  final ValueSelected onSelect;
  final FileTileSelectMode fileTileSelectMode;
  final DirectoryItem rootDirectory;
  LibsshWrapper? libsshWrapper;
  LibssOptions? libssOptions;

  FilesystemList({
    Key? key,
    this.isRoot = false,
    this.fsType = FilesystemType.all,
    this.folderIconColor,
    this.allowedExtensions,
    required this.onChange,
    required this.onSelect,
    required this.fileTileSelectMode,
    this.libsshWrapper,
    this.libssOptions,
    required this.rootDirectory,
  }) : super(key: key);

  Future<List<DirectoryItem>> _dirContents() async {
    if (libssOptions == null && libsshWrapper == null) {
      throw Exception('libssOptions or libsshWrapper instance is null');
    }

    libsshWrapper = libsshWrapper == null ? LibsshWrapper.fromOptions(libssOptions!) : libsshWrapper;
    if (libssOptions != null) {
      libsshWrapper!.connect();
    }

    var files = <DirectoryItem>[];
    List<DirectoryItem> list = libsshWrapper!.sftpListDir(rootDirectory.path);

    for (var file in list) {
      /*if (file.type == DirectoryItemType.file) {
        if ((allowedExtensions != null) && (allowedExtensions!.length > 0)) {
          if (!allowedExtensions!.contains(Path.extension(file.name))) {
            files.add(file);
          }
        }
      } else {
        files.add(file);
      }*/
      files.add(file);
    }

    if (libssOptions != null) {
      libsshWrapper!.dispose();
    }

    files.sort((a, b) => a.name.compareTo(b.path));

    return files;
  }

  InkWell _topNavigation() {
    return InkWell(
      child: const ListTile(
        leading: Icon(Icons.arrow_upward, size: 32),
        title: Text("..", textScaleFactor: 1.5),
      ),
      onTap: () {
        final li = this.rootDirectory.path.split('/');
        var dir = DirectoryItem.fromName('/');
        if (li.length > 2) {
          li.removeLast();
          dir = DirectoryItem.fromName('/${li.last}');
        }
        print('FilesystemList _topNavigation ${this.rootDirectory.path} li: $li');

        onChange(dir);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dirContents(),
      builder: (BuildContext context, AsyncSnapshot<List<DirectoryItem>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length + (isRoot ? 0 : 1),
            itemBuilder: (BuildContext context, int index) {
              if (!isRoot && index == 0) {
                return _topNavigation();
              }

              final item = snapshot.data![index - (isRoot ? 0 : 1)];
              return FilesystemListTile(
                fsType: fsType,
                item: item,
                folderIconColor: folderIconColor,
                onChange: onChange,
                onSelect: onSelect,
                fileTileSelectMode: fileTileSelectMode,
              );
            },
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
