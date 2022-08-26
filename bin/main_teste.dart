import 'dart:convert';
import 'dart:io';

import 'package:libssh_binding/libssh_binding.dart';
//import 'package:path/path.dart' as path;

void main() async {
  var password = utf8.decode(base64.decode('MDhkZXNlY3QwNQ=='));
  final libssh = LibsshWrapper('192.168.2.77', username: 'root', password: password, port: 22, verbosity: false);

  libssh.connect();
  final stopwatch = Stopwatch()..start();
  var items = libssh.sftpListDir('/var/www/html/teste/marcos/poo/projeto1_antigo_com_tudo');
  items.forEach((i) => print(i.nativePathAsString));

  print('main() items.length: ${items.length}');
  stopwatch.stop();
  print('\r\n${stopwatch.elapsedMilliseconds}ms ${stopwatch.elapsedMicroseconds}mics');
  libssh.dispose();
  exit(0);
}
