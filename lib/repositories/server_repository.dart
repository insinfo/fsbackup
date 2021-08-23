import 'package:fsbackup/models/server.dart';
import 'package:fsbackup/repositories/base_repository.dart';

class ServerRepository extends BaseRepository {
  ServerRepository();
  ServerRepository._();
  static final ServerRepository inst = ServerRepository._();

  Future<List<Server>> all() async {
    final db = await database;
    var result = await db.find();
    return result.map((m) => Server.fromMap(m as Map<String, dynamic>)).toList();
  }

  Future<Server> getById(String id) async {
    final db = await database;
    var result = await db.first({'id': id});
    return Server.fromMap(Map<String, dynamic>.from(result));
  }

  Future<Server> insert(Server server) async {
    final db = await database;
    var result = await db.insert(server.toMap());
    return server..id = result.toString();
  }

  Future<Server> update(Server server) async {
    final db = await database;
    await db.update({'id': server.id}, server.toMap());
    return server;
  }

  Future<void> remove(Server server) async {
    final db = await database;
    await db.remove({'id': server.id});
  }

  Future<void> removeById(String id) async {
    final db = await database;
    await db.remove({'id': id});
  }

  Future<void> removeAll() async {
    final db = await database;
    await db.cleanup();
  }
}
