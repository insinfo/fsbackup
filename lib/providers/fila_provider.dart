import 'package:flutter/material.dart';
import 'package:fsbackup/app_injector.dart';

import 'package:fsbackup/providers/log_provider.dart';
import 'package:fsbackup/repositories/backup_routine_repository.dart';
import 'package:fsbackup/services/backup_task.dart';
import 'package:fsbackup_shared/fsbackup_shared.dart';
import 'package:worker_isolated/worker_isolated.dart';

class FilaProvider extends ChangeNotifier {
  final BackupRoutineRepository repository;
  List<BackupRoutineModel> routines = <BackupRoutineModel>[];
  FilaProvider(this.repository);

  Future<void> start() async {
    routines = await repository.all();

    routines.forEach((rotina) async {
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

  Future<List<BackupRoutineModel>> getAll() async {
    return routines;
  }
}
