import 'package:fsbackup/providers/menu_provider.dart';
import 'package:fsbackup/providers/servidor_provider.dart';
import 'package:fsbackup/providers/tarefa_provider.dart';
import 'package:fsbackup/repositories/servidor_repository.dart';
import 'package:fsbackup/repositories/tarefa_repository.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;
Future appInjector() async {
  locator.registerSingleton<MenuProvider>(MenuProvider());

  locator.registerSingleton<ServidorRepository>(ServidorRepository());
  locator.registerSingleton<ServidorProvider>(ServidorProvider(locator<ServidorRepository>()));

  locator.registerSingleton<TarefaRepository>(TarefaRepository());
  locator.registerSingleton<TarefaProvider>(TarefaProvider(locator<TarefaRepository>()));

  await locator<ServidorRepository>().initDB();
  await locator<TarefaRepository>().initDB();

  return 1;
}
