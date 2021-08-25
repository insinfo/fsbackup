import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fsbackup/models/tarefa_backup.dart';
import 'package:fsbackup/repositories/tarefa_repository.dart';

class TarefaProvider with ChangeNotifier {
  final TarefaRepository repository;

  TarefaProvider(this.repository);

  /* final serverController = StreamController<List<Server>>();
   Stream get getServers => serverController.stream;
  void updateServers() async {
    serverController.sink.add(await repository.all());
  }*/

  Future<List<TarefaBackup>> getAll() async {
    return repository.all();
  }

  Future<void> insert(TarefaBackup server) async {
    await repository.insert(server);
    notifyListeners();
  }

  Future<void> update(TarefaBackup server) async {
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
