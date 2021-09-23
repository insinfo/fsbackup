import 'package:flutter/material.dart';
import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/models/rotina_backup.dart';
import 'package:fsbackup/providers/log_provider.dart';
import 'package:fsbackup/repositories/tarefa_repository.dart';
import 'package:fsbackup/services/backup_task.dart';
import 'package:fsbackup/worker/worker.dart';

class FilaProvider extends ChangeNotifier {
  final RotinaBackupRepository repository;
  List<RotinaBackup> rotinas = <RotinaBackup>[];
  FilaProvider(this.repository);

  Future<void> start() async {
    rotinas = await repository.all();

    rotinas.forEach((rotina) async {
      //var servidor = rotina.servidores.first;

      var task = BackupTask(rotina, taskId: rotina.id);
      final worker = Worker(poolSize: 1);
      await worker.handle(task, progressCallback: (TransferProgress progress) {
        //var progress = ((loaded / total) * 100).round();
        rotina.percent = (progress.loaded / progress.total) * 100;
        // rotina.status = progress.status;
        notifyListeners();
      }, logCallback: (TaskLog taskLog) {
        locator<LogProvider>().addLine(taskLog.log);
      });
    });

    notifyListeners();
  }

  Future<List<RotinaBackup>> getAll() async {
    return rotinas;
  }
}
