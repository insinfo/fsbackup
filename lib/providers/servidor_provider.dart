import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fsbackup/models/servidor.dart';
import 'package:fsbackup/repositories/server_repository.dart';

class ServidorProvider with ChangeNotifier {
  ServerRepository repository;

  ServidorProvider() {
    repository = ServerRepository();
  }

  Future<void> initializeDB() async {
    await repository.initializeDB();
  }
  /* final serverController = StreamController<List<Server>>();
   Stream get getServers => serverController.stream;
  void updateServers() async {
    serverController.sink.add(await repository.all());
  }*/

  Future<List<Servidor>> returnServers() async {
    return repository.all();
  }

  Future<void> insert(Servidor server) async {
    await repository.insert(server);
    notifyListeners();
  }

  Future<void> update(Servidor server) async {
    await repository.update(server);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await repository.removeById(id);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    await repository.removeAll();
    notifyListeners();
  }

  Future<dynamic> dispose() async {
    await repository.dispose();
    //await serverController.close();
    super.dispose();
  }
}
