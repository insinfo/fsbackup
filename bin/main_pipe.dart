import 'dart:async';
import 'dart:io';

import 'package:fsbackup_shared/fsbackup_shared.dart';
import 'package:os/file_system.dart';

var pipe = NamedPipeWindows('fsbackup2');
void main() {
  //var hd = CreateMutex();
  var countRunning = ProcessHelper.countProcessInstance('fsbackup.exe');
  if (countRunning > 1) {
    notifyOpenInstance().then((value) => exit(1));
  }
  startPipeServer();

  print('2');
}

Future<void> notifyOpenInstance() async {
  print('notifyInstace');
}

void startPipeServer() {
  pipe = NamedPipeWindows('fsbackup2');
  pipe.create();
  print('create');

  pipe.start((val) {
    print('pipe server: $val');
  });

  print('fim');
}
