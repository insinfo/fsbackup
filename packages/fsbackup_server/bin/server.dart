import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:fsbackup_server/fsbackup_server.dart';
import 'package:fsbackup_shared/fsbackup_shared.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

//serviço do windows baseado em https://stackoverflow.com/questions/21056419/how-do-you-run-a-dart-application-as-a-windows-service?rq=1
//executar a compilação
//dart compile exe .\bin\server.dart
//para registar um serviço no windows
//sc.exe create fsbackup_service binPath=D:\MyDartProjects\fsbackup\packages\fsbackup_server\bin\server.exe

//para remover um serviço no windows
//SC DELETE fsbackup_service

//import 'package:grpc/grpc.dart' as grpc;

// These two types represent the
// Init(...) function of the C API
// ignore: camel_case_types
typedef init_func = ffi.Int32 Function(ffi.Pointer<Utf8>);
typedef Init = int Function(ffi.Pointer<Utf8>);

// Entry point to the Dart application.
// When run as a Windows Service,
// this is still the entry point.
// This code is not embeded but is started
// as a regular console application.
void main() async {
  final init = createInit();

  // Starts the actual work in a separate Isolate
  await Isolate.spawn(run, 'message');

  final serviceName = CoreUtils.toUtf8('fsbackup_service');
  // calls the Init(...) function
  var result = init(serviceName);
  //1063 este erro ocorre se o usuário iniciar o programa manualmente
  //1063 (ERROR_FAILED_SERVICE_CONTROLLER_CONNECT)
  print('result: $result');
  //if (result != 0) return;

  // blocks this Isolate indefinitely from continuing
  while (true) {
    sleep(Duration(days: 365));
  }
}

// Creates the instance of the proxy to the Init(...)
// function.
Init createInit() {
  //PATH to the C compiled DLL
  final path = r'D:\MyDartProjects\fsbackup\packages\fsbackup_server\fsbackup_native\Release\fsbackup_service.dll';
  final dylib = ffi.DynamicLibrary.open(path);

  // ignore: omit_local_variable_types
  final Init init = dylib.lookup<ffi.NativeFunction<init_func>>('init').asFunction();
  return init;
}

// Performs the actual work that needs to
// be done, in this case, we are hosting
// a gRPC or shelf http service, but this should
// work with any other kind of
// payload, namely other types of
// http services.
void run(String message) async {
  print('inside isolate');
  /*var server = grpc.Server(
    [
// my service classes
    ],
  );
  await server.serve(port: 5001);*/
  final home = HomeController();
  // Create server
  // final server = await shelf_io.serve(home.handler, '127.0.0.1', 5001);
  // Server on message
  // print('☀️ Server running on localhost:${server.port} ☀️');

  HttpServer server = await HttpServer.bind('localhost', 5001);
  server.transform(WebSocketTransformer()).listen(onWebSocketData);
}

void onWebSocketData(WebSocket client) {
  client.listen((data) {
    client.add('Echo: $data');
  });
}
