import 'dart:async';
import 'package:flutter/material.dart';

import 'package:fsbackup/repositories/backup_routine_repository.dart';
import 'package:fsbackup_shared/fsbackup_shared.dart';

class BackupRoutineProvider with ChangeNotifier {
  final BackupRoutineRepository repository;

  BackupRoutineProvider(this.repository);

  /* final serverController = StreamController<List<Server>>();
   Stream get getServers => serverController.stream;
  void updateServers() async {
    serverController.sink.add(await repository.all());
  }*/

  Future<List<BackupRoutineModel>> getAll() async {
    return repository.all();
  }

  Future<void> insert(BackupRoutineModel routine) async {
    await repository.insert(routine);
    notifyListeners();
  }

  Future<void> update(BackupRoutineModel routine) async {
    await repository.update(routine);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await repository.removeById(id);
    notifyListeners();
  }

  Future<void> cleanLog(BackupRoutineModel routine) async {
    routine.log = '';
    await repository.update(routine);
    notifyListeners();
  }

  Future<dynamic> dispose() async {
    //await repository.localDatabase.dispose();
    //await serverController.close();
    super.dispose();
  }
}
