import 'package:fsbackup/providers/fila_provider.dart';
import 'package:fsbackup/providers/log_provider.dart';
import 'package:fsbackup/providers/menu_provider.dart';
import 'package:fsbackup/providers/server_provider.dart';
import 'package:fsbackup/providers/backup_routine_provider.dart';
import 'package:fsbackup/repositories/server_repository.dart';
import 'package:fsbackup/repositories/backup_routine_repository.dart';
import 'package:fsbackup/services/mongodb_service.dart';
import 'package:get_it/get_it.dart';
import 'package:cron/cron.dart';

GetIt locator = GetIt.instance;
bool isLoadedDb = false;
Future appInjector() async {
  if (isLoadedDb == false) {
    locator.registerSingleton<MongodbService>(MongodbService());
    await locator<MongodbService>().initDB();

    locator.registerSingleton<MenuProvider>(MenuProvider());

    locator.registerSingleton<ServerRepository>(ServerRepository(locator<MongodbService>()));
    locator.registerSingleton<ServerProvider>(ServerProvider(locator<ServerRepository>()));

    locator.registerSingleton<BackupRoutineRepository>(BackupRoutineRepository(locator<MongodbService>()));
    locator.registerSingleton<BackupRoutineProvider>(BackupRoutineProvider(locator<BackupRoutineRepository>()));

    locator.registerSingleton<FilaProvider>(FilaProvider(locator<BackupRoutineRepository>()));

    locator.registerSingleton<LogProvider>(LogProvider());

    locator.registerSingleton<Cron>(Cron());

    isLoadedDb = true;
  }

  return true;
}
