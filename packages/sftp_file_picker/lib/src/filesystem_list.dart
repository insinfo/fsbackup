import 'dart:async';

import 'package:flutter/material.dart';
import 'package:libssh_binding/libssh_binding.dart';

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
  final LibsshWrapper? libsshWrapper;
  final LibssOptions? libssOptions;

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
    try {
      if (libssOptions == null && libsshWrapper == null) {
        throw Exception('libssOptions or libsshWrapper instance is null');
      }

      var libssh = libsshWrapper == null ? LibsshWrapper.fromOptions(libssOptions!) : libsshWrapper!;
      if (libssOptions != null) {
        libssh.connect();
      }

      var files = <DirectoryItem>[];
      var list = libssh.sftpListDir(rootDirectory.path);

      for (var file in list) {
        if (file.name != '..' && file.name != '.') files.add(file);
      }

      if (libssOptions != null) {
        libssh.dispose();
      }

      files.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      return files;
    } catch (e) {
      return [];
      //throw UnableToOpenDirectory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dirContents(),
      builder: (BuildContext context, AsyncSnapshot<List<DirectoryItem>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length /*+ (isRoot ? 0 : 1)*/,
            itemBuilder: (BuildContext context, int index) {
              /*if (!isRoot && index == 0) {
                return _topNavigation();
              }*/

              final item = snapshot.data![index /*- (isRoot ? 0 : 1)*/];
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
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
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
