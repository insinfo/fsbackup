import 'package:libssh_binding/libssh_binding.dart';

void main() {
  final libssh = LibsshWrapper('192.168.133.13', username: 'isaque.neves', password: 'Ins257257', port: 22);
  libssh.connect();
  final start = DateTime.now();

  ///var/www/html/portal2018_invadido.tar.gz
  //download file via SCP
  /*await libssh.scpDownloadFileTo('/home/isaque.neves/go1.11.4.linux-amd64.tar.gz',
      path.join(Directory.current.path, 'go1.11.4.linux-amd64.tar.gz'), callbackStats: (total, loaded) {
    var progress = ((loaded / total) * 100).round();
    stdout.write('\r');
    stdout.write('\r[${List.filled(((progress / 10) * 4).round(), '=').join()}] $progress%');
  });*/

  var re = libssh.execCommandSync('cd /var/www; ls -l');
  print(re);
  //var re = libssh.execCommandsInShell(['cd /var/www', 'ls -l']);
  //print(re.join(''));
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

  print('${DateTime.now().difference(start)}');
  libssh.dispose();
}
