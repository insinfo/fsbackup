import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

const int _kMaxSmi64 = (1 << 62) - 1;
const int _kMaxSmi32 = (1 << 30) - 1;
final int _maxSize = sizeOf<IntPtr>() == 8 ? _kMaxSmi64 : _kMaxSmi32;

class CoreUtils {
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

  /// Creates a [String] containing the characters UTF-8 encoded in [string].
  ///
  /// The [string] must be a zero-terminated byte sequence of valid UTF-8
  /// encodings of Unicode code points. It may also contain UTF-8 encodings of
  /// unpaired surrogate code points, which is not otherwise valid UTF-8, but
  /// which may be created when encoding a Dart string containing an unpaired
  /// surrogate. See [Utf8Decoder] for details on decoding.
  ///
  /// Returns a Dart string containing the decoded code points.
  static String fromUtf8(Pointer<Utf8> string) {
    final length = strlen(string);
    return utf8.decode(Uint8List.view(string.cast<Uint8>().asTypedList(length).buffer, 0, length));
  }

  static int strlen(Pointer<Utf8> string) {
    final array = string.cast<Uint8>();
    final nativeString = array.asTypedList(_maxSize);
    return nativeString.indexWhere((char) => char == 0);
  }

  /// Convert a [String] to a Utf8-encoded null-terminated C string.
  ///
  /// If 'string' contains NULL bytes, the converted string will be truncated
  /// prematurely. Unpaired surrogate code points in [string] will be preserved
  /// in the UTF-8 encoded result. See [Utf8Encoder] for details on encoding.
  ///
  /// Returns a malloc-allocated pointer to the result.
  static Pointer<Utf8> toUtf8(String string, {Allocator allocator = calloc}) {
    final units = utf8.encode(string);
    final result = allocator<Uint8>(units.length + 1);
    final nativeString = result.asTypedList(units.length + 1);
    nativeString.setAll(0, units);
    nativeString[units.length] = 0;
    return result.cast();
  }
}
