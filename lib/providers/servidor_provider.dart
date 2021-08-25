import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fsbackup/models/servidor.dart';
import 'package:fsbackup/repositories/servidor_repository.dart';

class ServidorProvider with ChangeNotifier {
  final ServidorRepository repository;

  ServidorProvider(this.repository);

  /* final serverController = StreamController<List<Server>>();
   Stream get getServers => serverController.stream;
  void updateServers() async {
    serverController.sink.add(await repository.all());
  }*/

  Future<List<Servidor>> getAll() async {
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

  Future<dynamic> dispose() async {
    //await repository.localDatabase.dispose();
    //await serverController.close();
    super.dispose();
  }
}