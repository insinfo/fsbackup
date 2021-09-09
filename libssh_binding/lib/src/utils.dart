import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

Pointer<Void> stringToNativeVoid(String str, {Allocator allocator = malloc}) {
  final units = utf8.encode(str);
  final Pointer<Uint8> result = allocator<Uint8>(units.length + 1);
  final Uint8List nativeString = result.asTypedList(units.length + 1);
  nativeString.setAll(0, units);
  nativeString[units.length] = 0;
  return result.cast();
}

Pointer<Utf8> stringToNativeChar(String str, {Allocator allocator = malloc}) {
  final units = utf8.encode(str);
  final Pointer<Uint8> result = allocator<Uint8>(units.length + 1);
  final Uint8List nativeString = result.asTypedList(units.length + 1);
  nativeString.setAll(0, units);
  nativeString[units.length] = 0;
  return result.cast();
}

Pointer<Int8> stringToNativeInt8(String str, {Allocator allocator = malloc}) {
  final units = utf8.encode(str);
  final Pointer<Uint8> result = allocator<Uint8>(units.length + 1);
  final Uint8List nativeString = result.asTypedList(units.length + 1);
  nativeString.setAll(0, units);
  nativeString[units.length] = 0;
  return result.cast();
}

/*String nativeInt8ToString(Pointer<Int8> input){

}*/

Pointer<Void> intToNativeVoid(int number, {Allocator allocator = malloc}) {
  final ptr = malloc.allocate<Int32>(sizeOf<Int32>());
  ptr.value = number;
  return ptr.cast();
}
