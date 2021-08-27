import 'package:fsbackup/providers/fila_provider.dart';
import 'package:fsbackup/providers/menu_provider.dart';
import 'package:fsbackup/providers/servidor_provider.dart';
import 'package:fsbackup/providers/rotina_backup_provider.dart';
import 'package:fsbackup/repositories/servidor_repository.dart';
import 'package:fsbackup/repositories/tarefa_repository.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;
bool isLoadedDb = false;
Future appInjector() async {
  if (isLoadedDb == false) {
    locator.registerSingleton<MenuProvider>(MenuProvider());

    locator.registerSingleton<ServidorRepository>(ServidorRepository());
    locator.registerSingleton<ServidorProvider>(ServidorProvider(locator<ServidorRepository>()));

    locator.registerSingleton<RotinaBackupRepository>(RotinaBackupRepository());
    locator.registerSingleton<RotinaBackupProvider>(RotinaBackupProvider(locator<RotinaBackupRepository>()));

    locator.registerSingleton<FilaProvider>(FilaProvider(locator<RotinaBackupRepository>()));

    await locator<ServidorRepository>().initDB();
    await locator<RotinaBackupRepository>().initDB();
    isLoadedDb = true;
  }

  return true;
}
