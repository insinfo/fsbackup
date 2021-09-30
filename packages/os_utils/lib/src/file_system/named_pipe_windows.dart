import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as ffi;
import 'package:os/src/cancellation_token.dart';
import 'package:win32/win32.dart';

/// Duration before polling again.
const _shortDuration = Duration(microseconds: 100);

ffi.Pointer<ffi.Utf16> stringToNativeUtf16(String str, {ffi.Allocator allocator = ffi.malloc}) {
  final units = str.codeUnits;
  final result = allocator<ffi.Uint16>(units.length + 1);
  final nativeString = result.asTypedList(units.length + 1);
  nativeString.setRange(0, units.length, units);
  nativeString[units.length] = 0;
  return result.cast();
}

class NamedPipeWindows {
  String path;
  int mhPipe; //HANDLE
  static const NMPWAIT_USE_DEFAULT_WAIT = 0x00000000;
  static const ERROR_PIPE_CONNECTED = 0x80070217;
  bool mClientConnected = false;

  ///sprintf(pipe_name, "\\\\.\\pipe\\%s\\%s_pipe", username, app_name);
  NamedPipeWindows(String pipeName) {
    path = '\\\\.\\pipe\\$pipeName';
  }

  CancellationToken getCancellationToken() {
    return CancellationToken();
  }

  /// Creates the named pipe.
  void create({ffi.Allocator allocator = ffi.calloc}) {
    mhPipe = CreateNamedPipe(
        stringToNativeUtf16(path, allocator: allocator),
        PIPE_ACCESS_DUPLEX,
        PIPE_TYPE_BYTE |
            PIPE_READMODE_BYTE |
            // PIPE_NOWAIT,
            PIPE_WAIT, // FILE_FLAG_FIRST_PIPE_INSTANCE is not needed but forces CreateNamedPipe(..) to fail if the pipe already exists...
        1,
        1024 * 16,
        1024 * 16,
        0, //NMPWAIT_USE_DEFAULT_WAIT
        ffi.nullptr);

    if (mhPipe != INVALID_HANDLE_VALUE) {
      print('Named pipe created');
    } else {
      //throw Exception('Failed to create NamedPipe');
    }
  }

  bool connect() {
    if (mClientConnected == true) {
      DisconnectNamedPipe(mhPipe);
    }
    var rc = ConnectNamedPipe(mhPipe, ffi.nullptr);

    if (rc == FALSE) {
      // It is possible that a client connects before the ConnectNamedPipe is invoked after CreateNamed Pipe.
      // Connections is still good!
      //  Ref: https://msdn.microsoft.com/query/dev15.query?appId=Dev15IDEF1&l=EN-US&k=k(NAMEDPIPEAPI/ConnectNamedPipe);k(ConnectNamedPipe);k(DevLang-C++);k(TargetOS-Windows)&rd=true
      var error = GetLastError();
      if (error == ERROR_PIPE_CONNECTED) {
        mClientConnected = true;
        return true;
      }

      mClientConnected = false;
      throw Exception('Failed to connect $error');
      //return false;
    }

    mClientConnected = true;
    return true;
  }

  /// Deletes the named pipe.
  ///
  /// Note that usually named pipes can't be deleted with normal file
  /// operations.
  bool disconnect() {
    mClientConnected = false;
    if (DisconnectNamedPipe(mhPipe) == FALSE) {
      return false;
    }

    return true;
  }

  bool destroy() {
    if (mhPipe != INVALID_HANDLE_VALUE) {
      if (mClientConnected == true) {
        DisconnectNamedPipe(mhPipe);
        mClientConnected = false;
      }

      CloseHandle(mhPipe);
      mhPipe = INVALID_HANDLE_VALUE;
    }
    clearObject();
    return true;
  }

  void clearObject() {
    mhPipe = INVALID_HANDLE_VALUE;
  }

  void start(Function(String value) callback,
      {ffi.Allocator allocator = ffi.calloc}) {
    //final future = Future<void>.value();
    //return future.whenComplete(() {
    ffi.Pointer<ffi.Uint32> dwRead;
    ffi.Pointer<ffi.Uint8> buffer;

    try {
      while (mhPipe != INVALID_HANDLE_VALUE) {       
        //if (ConnectNamedPipe(mhPipe, ffi.nullptr) == TRUE) {
        if (connect()) {
          //Setting a breakpoint here will never trigger.
          dwRead = allocator<ffi.Uint32>(1);
          final bufferLength = 1024;
          buffer = allocator<ffi.Uint8>(bufferLength);
          while (ReadFile(mhPipe, buffer, (ffi.sizeOf<ffi.Uint8>() * bufferLength) - 1, dwRead, ffi.nullptr) == TRUE) {
            var bufferData = buffer.asTypedList(dwRead.value);
            callback(utf8.decode(bufferData));
          }
        }
        //DisconnectNamedPipe(mhPipe);
        disconnect();
      }
    } finally {
      allocator.free(dwRead);
      allocator.free(buffer);
    }
    //});
  }

  /// Opens the named pipe for reading as Stream.
  Stream<String> openReadAsStream({ffi.Allocator allocator = ffi.calloc}) {
    final streamController = StreamController<String>();
    streamController.onListen = () {
      // Allocate a buffer that can be filled by 'libc'
      final bufferLength = 1024;
      final buffer = allocator<ffi.Uint8>(bufferLength);
      // Periodically check whether any data has arrived
      Timer.periodic(_shortDuration, (timer) {
        connect();
        // If the stream is closed
        if (streamController.isClosed) {
          // Cancel timer
          timer.cancel();
          // Free memory
          allocator.free(buffer);
          // Close file handle
          destroy();
          return;
        }
        final dwRead = allocator<ffi.Uint32>(1);
        // Read
        final result = ReadFile(mhPipe, buffer, (ffi.sizeOf<ffi.Uint8>() * bufferLength) - 1, dwRead, ffi.nullptr);
        if (result == TRUE) {
          /* add terminating zero */
          buffer[dwRead.value] = 0;
          // We received data.
          // We need to allocate a new Uint8List that we can pass to the listener.
          //final readData = buffer.asTypedList(dwRead.value);
          var bufferData = buffer.asTypedList(dwRead.value);
          //readData.setAll(0, bufferData.take(result));
          streamController.add(utf8.decode(bufferData));
        }
        if (dwRead.value < 0) {
          print('failed to read pipe ${GetLastError()}');
          final error = Exception('failed to read pipe');
          streamController.addError(error);
          streamController.close();
          return;
        }
      });
      //libc.write(pollFd.fd, 0, 0);
    };
    return streamController.stream;
  }

  /// Opens the named pipe for writing.
  ///
  /// Optional parameter [timeout] defines how long to wait for readers to open
  /// the pipe.
  NamedPipeWriter openWrite() {
    return NamedPipeWriter(path);
  }
}

class NamedPipeWriter implements Sink<List<int>>, StreamConsumer<List<int>> {
  final String path;

  Future<void> _future;
  bool _isClosed = false;

  int mhPipe;

  NamedPipeWriter(this.path);

  Future<void> addString(String data) {
    return add(data.codeUnits);
  }

  @override
  Future<void> add(List<int> data) {
    if (_isClosed) {
      throw StateError('The sink is closed');
    }

    final newFuture = _add(data);
    _future = newFuture;
    return newFuture;
  }

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (var chunk in stream) {
      await add(chunk);
    }
  }

  void connect({ffi.Allocator allocator = ffi.calloc}) {
    mhPipe = CreateFile(stringToNativeUtf16(path, allocator: allocator), GENERIC_READ | GENERIC_WRITE, 0, ffi.nullptr,
        OPEN_EXISTING, 0, NULL);
    if (mhPipe != INVALID_HANDLE_VALUE) {
      print('Connected to named pipe');
    } else {
      throw Exception('Failed to create Named Pipe, the server is not running ');
    }
  }

  @override
  Future<void> close() {
    _isClosed = true;
    final future = _future ?? Future<void>.value();
    return future.whenComplete(() {
      print('Close named pipe');
      CloseHandle(mhPipe);
    });
  }

  Future<void> _add(List<int> data, {ffi.Allocator allocator = ffi.calloc}) async {
    // If empty, we can skip allocation
    if (data.isEmpty) {
      return;
    }

    // Allocate buffer than 'libc' can use
    final bufferLength = data.length;
    final pointer = allocator<ffi.Uint8>(bufferLength);

    try {
      // Declare remaining pointer/length
      var remainingPointer = pointer;
      var remainingLength = bufferLength;

      // Copy data
      final pointerData = pointer.asTypedList(bufferLength);
      pointerData.setAll(0, data);

      // While we have remaining bytes
      while (remainingLength > 0) {
        if (_isClosed) {
          throw StateError('The sink is closed');
        }

        // Write
        //final n = libc.write(_fd, remainingPointer, remainingLength);
        final dwWritten = allocator<ffi.Uint32>(1);
        final rc = WriteFile(
            mhPipe,
            remainingPointer,
            remainingLength, // = length of string + terminating '\0' !!!
            dwWritten,
            ffi.nullptr);

        // An error?
        if (rc == FALSE) {
          throw Exception('failed to Write to pipe');
        }

        // Wrote something?
        if (dwWritten.value > 0) {
          remainingPointer = remainingPointer.elementAt(dwWritten.value);
          remainingLength -= dwWritten.value;
          if (remainingLength == 0) {
            return;
          }
        }

        // Wait a bit before trying again
        await Future.delayed(_shortDuration);
      }
    } finally {
      allocator.free(pointer);
    }
  }
}
