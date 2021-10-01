import 'package:cron/cron.dart';
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
  TelegramService telegramService;
  LogProvider logProvider;
  bool isRunning = false;

  Cron cron;
  Queue backupQueue;

  BackupService(this.repository, this.dashboardProvider) {
    telegramService = TelegramService();
    telegramService.init();
  }
  Future<void> start() async {
    if (isRunning == false) {
      logProvider = locator<LogProvider>();
      cron = Cron();
      backupQueue = Queue();
      print('BackupService Cron start');
      dashboardProvider.routines.clear();
      dashboardProvider.routines = await repository.all();
      dashboardProvider.routines?.forEach((rotina) {
        if (rotina.startBackup == StartBackup.scheduled) {
          cron.schedule(
            Schedule.parse(rotina.whenToBackup),
            () => backupQueue.add(() => _task(rotina)),
          );
        } else {
          backupQueue.add(() => _task(rotina));
        }
      });
      dashboardProvider.updateUi();
    }

    isRunning = true;
  }

  Future<dynamic> _task(BackupRoutineModel rotina) async {
    print('executando rotina ${rotina.name}');

    var task = BackupTask(rotina, taskId: rotina.id);

    rotina.log = '';

    final worker = Worker(poolSize: 1);

    try {
      rotina.status = RoutineStatus.progress;
      await worker.handle(task, progressCallback: (TransferProgress progress) {
        rotina.percent = (progress.loaded / progress.total) * 100;
        dashboardProvider.updateUi();
      }, logCallback: (TaskLog taskLog) {
        rotina.log += '${taskLog.log}\r\n';
        logProvider.addLine(taskLog.log);
      });
      rotina.status = RoutineStatus.waiting;
    } catch (e) {
      rotina.status = RoutineStatus.failed;
      telegramService.sendMessage('Erro no backup da rotina ${rotina.name}');
    }

    repository.update(rotina);
    //fim
  }

  Future<void> restart() async {
    stop();
    start();
  }

  Future<void> stop() async {
    if (isRunning) {
      await cron.close();
      backupQueue?.cancel();
      backupQueue?.dispose();
      dashboardProvider.routines.clear();
      dashboardProvider.updateUi();
    }
    isRunning = false;
  }
}
