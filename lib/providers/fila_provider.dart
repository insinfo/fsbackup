import 'package:flutter/material.dart';
import 'package:fsbackup/models/rotina_backup.dart';
import 'package:fsbackup/repositories/tarefa_repository.dart';

class FilaProvider extends ChangeNotifier {
  final RotinaBackupRepository repository;
  List<RotinaBackup> rotinas = <RotinaBackup>[];
  FilaProvider(this.repository);

  Future<void> start() async {
    rotinas = await repository.all();

    rotinas.forEach((rotina) async {
      //var servidor = rotina.servidores.first;

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
