import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
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

String nativeInt8ToString(Pointer<Int8> pointer, {allowMalformed: true}) {
  var ptrName = pointer.cast<Utf8>();
  final ptrNameCodeUnits = pointer.cast<Uint8>();
  var list = ptrNameCodeUnits.asTypedList(ptrName.length);
  return utf8.decode(list, allowMalformed: allowMalformed);
}

Uint8List  nativeInt8CodeUnits(Pointer<Int8> pointer) {
  var ptrName = pointer.cast<Utf8>();
  final ptrNameCodeUnits = pointer.cast<Uint8>();
  var list = ptrNameCodeUnits.asTypedList(ptrName.length);
  return list;
}

/*String nativeInt8ToString(Pointer<Int8> input){

}*/

Pointer<Void> intToNativeVoid(int number, {Allocator allocator = malloc}) {
  final ptr = malloc.allocate<Int32>(sizeOf<Int32>());
  ptr.value = number;
  return ptr.cast();
}

Future writeAndFlush(IOSink sink, object) {
  return sink.addStream((StreamController<List<int>>(sync: true)
        ..add(utf8.encode(object.toString()))
        ..close())
      .stream);
}
