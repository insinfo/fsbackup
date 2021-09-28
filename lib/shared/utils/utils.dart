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

  static Future<String> createDirectoryIfNotExist(String path) async {
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

  static Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  static truncateString(String str, int n, {bool useWordBoundary = false}) {
    if (str.length <= n) {
      return str;
    }
    final subString = str.substring(0, n - 1); // the original check
    return (useWordBoundary ? subString.substring(0, subString.lastIndexOf(" ")) : subString) + "..."; //&hellip;
  }

  static truncateMidleString(String str, int length, {int threshold = 3, String separator = '...'}) {
    if (str.length <= length) {
      return str;
    }
    threshold = threshold > length ? 0 : threshold;

    var partSize = (length / 2).round();
    var start = str.substring(0, partSize - threshold);
    var end = str.substring(str.length - (partSize + threshold));
    return '$start$separator$end';
  }

  static truncateMidleString2(String fullStr, int strLen, {String separator = '...'}) {
    if (fullStr.length <= strLen) return fullStr;

    var sepLen = separator.length,
        charsToShow = strLen - sepLen,
        frontChars = (charsToShow / 2).ceil(),
        backChars = (charsToShow / 2).floor();

    return fullStr.substring(0, frontChars) + separator + fullStr.substring(fullStr.length - backChars);
  }

  static truncateStartString(String str, int n) {
    if (str.length <= n) {
      return str;
    }

    var end = str.substring(str.length - n);

    return '...$end';
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
