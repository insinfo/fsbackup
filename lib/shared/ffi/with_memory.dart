import 'dart:ffi';

import 'package:ffi/ffi.dart';

/// Allocates a chunk of native memory, calls [action] and
/// then frees the memory even if an exception is thrown.
R withMemory<R, T extends NativeType>(int size, R Function(Pointer<T> memory) action) {
  final memory = calloc<Int8>(size);
  try {
    return action(memory.cast());
  } finally {
    calloc.free(memory);
  }
}
