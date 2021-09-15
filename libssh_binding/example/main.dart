import 'dart:io';

import 'package:libssh_binding/libssh_binding.dart';
import 'package:libssh_binding/src/extensions/sftp_extension.dart';
import 'dart:ffi' as ffi;
import 'package:path/path.dart' as path;

void main() async {
  // Open the dynamic library
  var libraryPath = path.join(Directory.current.path, 'libssh_compiled', 'ssh.dll');
  final dll = ffi.DynamicLibrary.open(libraryPath);
  var libssh = Libssh(dll);

  var host = "192.168.133.13";
  var port = 22;
  var password = "Ins257257";
  var username = "isaque.neves";

  // Abra a sessão e define as opções
  var my_ssh_session = libssh.ssh_new();
  libssh.ssh_options_set(my_ssh_session, ssh_options_e.SSH_OPTIONS_HOST, stringToNativeVoid(host));
  libssh.ssh_options_set(my_ssh_session, ssh_options_e.SSH_OPTIONS_PORT, intToNativeVoid(port));
  //libssh.ssh_options_set(my_ssh_session, ssh_options_e.SSH_OPTIONS_LOG_VERBOSITY, intToNativeVoid(SSH_LOG_PROTOCOL));
  libssh.ssh_options_set(my_ssh_session, ssh_options_e.SSH_OPTIONS_USER, stringToNativeVoid(username));
  // Conecte-se ao servidor
  var rc = libssh.ssh_connect(my_ssh_session);
  if (rc != SSH_OK) {
    print('Error connecting to host: $host\n');
  }

  rc = libssh.ssh_userauth_password(my_ssh_session, stringToNativeInt8(username), stringToNativeInt8(password));
  if (rc != ssh_auth_e.SSH_AUTH_SUCCESS) {
    var error = libssh.ssh_get_error(my_ssh_session.cast());
    print("Error authenticating with password:$error\n");
    //ssh_disconnect(my_ssh_session);
    //ssh_free(my_ssh_session);
  }
  String resp = '';
  // resp = libssh.execCommand(my_ssh_session, 'ls -l');
  //print("$resp");
  /*resp = libssh.execCommand(my_ssh_session, 'cd /var/www/dart && ls -l');
  print("$resp");*/

  /*resp = libssh.scpReadFileAsString(my_ssh_session, '/home/isaque.neves/teste.txt');
  print('$resp');*/

  var start = DateTime.now();

  await libssh.scpDownloadFileTo(my_ssh_session, '/var/www/html/portal2018_invadido.tar.gz',
      path.join(Directory.current.path, 'portal2018_invadido.tar.gz'));

  /* await libssh.sftpDownloadFileTo(my_ssh_session, '/home/isaque.neves/go1.11.4.linux-amd64.tar.gz',
      path.join(Directory.current.path, 'go1.11.4.linux-amd64.tar.gz'));*/

  /*await libssh.sftpCopyLocalFileToRemote(
      my_ssh_session, path.join(Directory.current.path, 'teste.mp4'), '/home/isaque.neves/teste.mp4');*/
  //sleep(Duration(seconds: 20));

  //print(path.join(Directory.current.path, 'go1.11.4.linux-amd64.tar.gz'));
  /*var sftp = libssh.initSftp(my_ssh_session);
  for (var i = 0; i < 10; i++) {
    
    await libssh.sftpDownloadFileTo(my_ssh_session, '/home/isaque.neves/go1.11.4.linux-amd64.tar.gz',
        path.join(Directory.current.path, 'go1.11.4.linux-amd64.tar.gz'),
        inSftp: sftp);
  }*/

  print(DateTime.now().difference(start));
  //sleep(Duration(minutes: 30));
  libssh.ssh_disconnect(my_ssh_session);
  libssh.ssh_free(my_ssh_session);
  //sleep(Duration(minutes: 50));

  exit(0);
}
