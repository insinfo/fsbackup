import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fsbackup/models/backup_routine_model.dart';
import 'package:fsbackup/repositories/backup_routine_repository.dart';

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

  Future<void> insert(BackupRoutineModel server) async {
    await repository.insert(server);
    notifyListeners();
  }

  Future<void> update(BackupRoutineModel server) async {
    await repository.update(server);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await repository.removeById(id);
    notifyListeners();
  }

  Future<dynamic> dispose() async {
    //await repository.localDatabase.dispose();
    //await serverController.close();
    super.dispose();
  }
}
