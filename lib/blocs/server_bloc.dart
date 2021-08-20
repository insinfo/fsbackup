import 'dart:async';

import 'package:fsbackup/models/server.dart';
import 'package:fsbackup/repositories/server_repository.dart';

class ServerBloc {
  final serverController = StreamController<List<Server>>();
  Stream get getServers => serverController.stream;
  ServerRepository repository;
  ServerBloc() {
    repository = ServerRepository();
  }

  void updateServers() async {
    serverController.sink.add(await repository.all());
  }

  Future<void> add(Server server) async {
    await repository.insert(server);
    updateServers();
  }

  Future<void> edit(Server server) async {
    await repository.update(server);
    updateServers();
  }

  Future<void> delete(String id) async {
    await repository.removeById(id);
    updateServers();
  }

  Future<void> deleteAll() async {
    await repository.removeAll();
    updateServers();
  }

  Future<dynamic> dispose() async {
    await repository.dispose();
    return serverController.close();
  }
}

final serverBloc = ServerBloc(); // create an instance of the bloc
