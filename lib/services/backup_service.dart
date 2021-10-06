import 'package:cron/cron.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/providers/fila_provider.dart';
import 'package:fsbackup/providers/log_provider.dart';
import 'package:fsbackup/repositories/backup_routine_repository.dart';
import 'package:fsbackup/services/backup_task.dart';
import 'package:fsbackup/services/telegram_service.dart';
import 'package:fsbackup_shared/fsbackup_shared.dart';
import 'package:queue/queue.dart';
import 'package:worker_isolated/worker_isolated.dart';

class BackupService {
  final BackupRoutineRepository repository;
  final FilaProvider dashboardProvider;

  LogProvider logProvider;
  bool isRunning = false;

  Cron cron;
  Queue backupQueue;

  BackupService(this.repository, this.dashboardProvider) {
    //
  }
  Future<void> start() async {
    if (isRunning == false) {
      logProvider = locator<LogProvider>();
      cron = Cron();
      backupQueue = Queue();
      print('BackupService Cron start');
      dashboardProvider.routines.clear();
      dashboardProvider.routines = await repository.all();
      if (dashboardProvider.routines != null) {
        for (var rotina in dashboardProvider.routines) {
          if (rotina.startBackup == StartBackup.scheduled) {
            cron.schedule(
              Schedule.parse(rotina.whenToBackup),
              () => backupQueue.add(() => _task(rotina)),
            );
          } else {
            backupQueue.add(() => _task(rotina));
          }
        }
      }
      dashboardProvider.updateUi();
    }

    isRunning = true;
  }

  Future<dynamic> _task(BackupRoutineModel rotina) async {
    print('executando rotina ${rotina.name}');

    var task = BackupTask(rotina.cloneWithoutHandleCancel(), taskId: rotina.id);
    rotina.log = '';
    final worker = Worker(poolSize: 1);
    rotina.handleCancel = () async {
      await worker.cancel();
    };

    try {
      rotina.status = RoutineStatus.progress;
      await worker.handle(task, progressCallback: (TransferProgress progress) {
        rotina.percent = (progress.loaded / progress.total) * 100;
        dashboardProvider.updateUi();
      }, logCallback: (TaskLog taskLog) {
        rotina.log += '${taskLog.log}\r\n';
        logProvider.addLine(taskLog.log);
      });
      rotina.lastBackup = DateTime.now();
      rotina.status = RoutineStatus.waiting;
    } catch (e, s) {
      rotina.percent = 0;
      rotina.status = RoutineStatus.failed;

      FLog.info(
        className: 'BackupService',
        methodName: '_task',
        text: 'Erro na execução da rotina de backup: ${rotina.name}',
        /* type: LogLevel.SEVERE,
          exception: e,
          stacktrace: s*/
      );

      var t = TelegramService();
      await t.init();
      await t.sendMessage(
          'Erro na execução da rotina de backup: ${rotina.name}\r\nLog:\r\n${rotina.log}');
    }

    repository.update(rotina);
    dashboardProvider.updateUi();
    //fim
  }

  Future<void> restart() async {
    await stop();
    start();
  }

  Future<void> stop() async {
    if (isRunning) {
      if (dashboardProvider.routines != null) {
        for (var rotina in dashboardProvider.routines) {
          if (rotina.handleCancel is Future Function()) {
            await rotina.handleCancel();
          }
        }
      }
      await cron.close();
      backupQueue?.cancel();
      backupQueue?.dispose();
      dashboardProvider.routines.clear();

      dashboardProvider.updateUi();
    }
    isRunning = false;
  }
}
