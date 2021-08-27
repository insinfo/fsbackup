import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fsbackup/models/rotina_backup.dart';
import 'package:fsbackup/repositories/tarefa_repository.dart';

class RotinaBackupProvider with ChangeNotifier {
  final RotinaBackupRepository repository;

  RotinaBackupProvider(this.repository);

  /* final serverController = StreamController<List<Server>>();
   Stream get getServers => serverController.stream;
  void updateServers() async {
    serverController.sink.add(await repository.all());
  }*/

  Future<List<RotinaBackup>> getAll() async {
    return repository.all();
  }

  Future<void> insert(RotinaBackup server) async {
    await repository.insert(server);
    notifyListeners();
  }

  Future<void> update(RotinaBackup server) async {
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
