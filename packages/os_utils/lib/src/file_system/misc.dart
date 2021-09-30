// Copyright 2019 terrier989 <terrier989@gmail.com>.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:ffi';

import 'dart:io';

import 'package:ffi/ffi.dart' as ffi;
import 'package:os/src/utils.dart';

import '../libc/all.dart' as libc;

/// Changes permissions of a file.
///
/// In windows, this function doesn't do anything.
Future<void> chmod(FileSystemEntity entity, int mode) async {
  chmodSync(entity, mode);
}

/// Changes permissions of a file.
///
/// In windows, this function doesn't do anything.
void chmodSync(FileSystemEntity entity, int mode, {Allocator allocator = ffi.calloc}) {
  if (Platform.isWindows) {
    throw UnsupportedError('Not supported in Windows');
  }
  final pathAddr = Utils.toUtf8(entity.path);
  try {
    final result = libc.chmod(pathAddr, mode);
    if (result < 0) {
      throw StateError('Error code: ${libc.errorDescription}');
    }
  } finally {
    allocator.free(pathAddr);
  }
}
