import 'package:flutter/material.dart';
import 'package:fsbackup/models/rotina_backup.dart';
import 'package:fsbackup/repositories/tarefa_repository.dart';

import 'package:fsbackup/services/ssh_service.dart';

class FilaProvider extends ChangeNotifier {
  final RotinaBackupRepository repository;
  List<RotinaBackup> rotinas = <RotinaBackup>[];
  FilaProvider(this.repository);

  Future<void> start() async {
    rotinas = await repository.all();

    rotinas.forEach((rotina) async {
      var servidor = rotina.servidores.first;
      print(servidor.nome);
      var ssh = SshService(
        uri: Uri.parse('ssh://${servidor.host}:${servidor.port}'),
        user: servidor.user,
        pass: servidor.password,
      );

      await ssh.connnect();
      print('final da conexão');
      var resp = await ssh.sendCommand('cd /var/www/dart \n');
      resp = await ssh.sendCommand('ls \n');
      print(resp);

      /*var downloadTask = BackupTask(rotina, taskId: rotina.id);
      final worker = Worker(poolSize: 1);
      await worker.handle(downloadTask, callback: (TransferProgress progress) {
        rotina.percent = progress.count / progress.total;
        rotina.status = progress.status;
        notifyListeners();
      });*/
    });

    notifyListeners();
  }

  Future<List<RotinaBackup>> getAll() async {
    return rotinas;
  }
}
