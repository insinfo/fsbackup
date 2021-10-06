import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
  static List<Widget> rowGap(double gap, Iterable<Widget> children) {
    return children.expand<Widget>((child) sync* {
      yield SizedBox(width: gap);
      yield child;
    }).toList();
  }

  static List<Widget> columnGap(double gap, Iterable<Widget> children) {
    return children.expand<Widget>((child) sync* {
      yield SizedBox(height: gap);
      yield child;
    }).toList();
  }

  static Future<Directory> getDownloadDirectory(String path) async {
    final dir = await getApplicationDocumentsDirectory();

    var downloadPath = '${dir.path}/$path';

    final myDir = Directory(downloadPath);
    if (myDir.existsSync()) {
      return myDir;
    } else {
      await myDir.create(recursive: true);
    }

    return myDir;
  }

  static Future<String> createDirectoryIfNotExistInDocuments(
      String path) async {
    final dir = await getApplicationDocumentsDirectory();

    var downloadPath = '${dir.path}/$path';

    final myDir = Directory(downloadPath);
    if (myDir.existsSync()) {
      return myDir.path;
    } else {
      await myDir.create(recursive: true);
    }
    var p = myDir.path;

    return p;
  }

  static String createDirectoryIfNotExist(String path) {
    final myDir = Directory(path);
    if (myDir.existsSync()) {
      return myDir.path;
    } else {
      myDir.createSync(recursive: true);
    }
    var p = myDir.path;
    return p;
  }

  static Future<Directory> createDirectoryIfNotExist2(String path) async {
    final myDir = Directory(path);
    if (myDir.existsSync()) {
      return myDir;
    } else {
      await myDir.create(recursive: true);
    }
    return myDir;
  }

  static Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  /*import 'package:fluttertoast/fluttertoast.dart';
  static void showToast(
    String msg, {
    Toast length = Toast.LENGTH_SHORT,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: length,
      gravity: gravity,
      textColor: Colors.white,
      backgroundColor: Colors.black.withOpacity(0.7),
    );
  }*/
}
