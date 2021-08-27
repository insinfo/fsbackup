import 'dart:async';
import 'dart:convert';

import 'package:dartssh/client.dart';

class SshService {
  final Uri uri;
  final String user;
  final String pass;
  SSHClient client;
  bool isConnected = false;
  StreamController<String> outStream;

  SshService({
    this.uri,
    this.user,
    this.pass,
  });

  Future<dynamic> connnect() {
    var completer = Completer<bool>();
    outStream = StreamController<String>.broadcast();
    try {
      client = SSHClient(
        hostport: uri,
        login: user,
        print: print,
        termWidth: 80,
        termHeight: 25,
        termvar: 'xterm-256color',
        getPassword: () => utf8.encode(pass),
        response: (transport, data) async {
          //print('SshService@response: ${utf8.decode(data)}');
          outStream.add(utf8.decode(data));
        },
        success: () {
          isConnected = true;
          Future.delayed(Duration(seconds: 1)).then((value) => completer.complete());
          print('SshService@success');
        },
        disconnected: () {
          print('SshService@disconnected');
          isConnected = false;
        },
      );
    } catch (e, s) {
      print('SshService@connnect $e $s');
      //completer.complete();
      completer.completeError(e, s);
    }
    return completer.future;
  }

  Future<String> sendCommand(String cmd) async {
    var completer = Completer<String>();
    try {
      client.sendChannelData(utf8.encode(cmd));
      var isEnd = false;
      var result = '';
      outStream.stream.listen((data) {
        //isaque.neves@laravel:/var/www/dart$
        result += data;
        if (data.trim().endsWith('\$')) {
          //print('stream.listen $data');
          if (isEnd == false) {
            isEnd = true;
            completer.complete(result);
          }
        }
      });
    } catch (e, s) {
      print('SshService@sendCommand $e $s');
      completer.completeError(e, s);
    }
    return completer.future;
  }

  void close() {
    client?.disconnect('terminate');
    outStream?.close();
  }
}
