import 'dart:async';

import 'package:flutter/material.dart';

import 'package:fsbackup/repositories/server_repository.dart';
import 'package:fsbackup_shared/fsbackup_shared.dart';

class ServerProvider with ChangeNotifier {
  final ServerRepository repository;

  ServerProvider(this.repository);

  /* final serverController = StreamController<List<Server>>();
   Stream get getServers => serverController.stream;
  void updateServers() async {
    serverController.sink.add(await repository.all());
  }*/

  Future<List<ServerModel>> getAll() async {
    return repository.all();
  }

  Future<void> insert(ServerModel server) async {
    await repository.insert(server);
    notifyListeners();
  }

  Future<void> update(ServerModel server) async {
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
