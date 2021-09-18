/*
import 'package:dartssh/client.dart';

class SshService {
  final Uri uri;
  final String user;
  final String pass;
  SSHClient client;
  bool isConnected = false;
  StreamController<String> outStream;
  StreamSubscription _streamSubscription;

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

  Future<List<String>> sendCommand(String cmd) async {
    var completer = Completer<List<String>>();
    try {
      var isEnd = false;
      var lines = <String>[];
      _streamSubscription = outStream.stream.listen((line) {
        //isaque.neves@laravel:/var/www/dart$
        lines.add(line);
        var l = line.trim();
        if (l.startsWith('$user@')) {
          if (l.endsWith('\$') || l.endsWith('#')) {
            //print('stream.listen $data');
            if (isEnd == false) {
              isEnd = true;
              _streamSubscription.cancel();
              completer.complete(lines);
            }
          }
        }
      });
      client.sendChannelData(utf8.encode(cmd + ' \n'));
    } catch (e, s) {
      print('SshService@sendCommand $e $s');
      completer.completeError(e, s);
    }
    return completer.future;
  }

  Future<String> execCommand(String cmd, {bool ignoreFirstAndLastLine = true}) async {
    var lines = await sendCommand(cmd);

    if (ignoreFirstAndLastLine) {
      if (lines.length < 3) {
        return '';
      } else {
        lines.removeRange(0, 1);
        lines.removeLast();
      }
    }

    return lines.join();
  }

  Future<void> close() async {
    client.disconnect('terminate');
    await outStream.close();
  }
}
*/
