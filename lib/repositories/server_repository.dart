import 'package:fsbackup/models/servidor.dart';
import 'package:fsbackup/repositories/base_repository.dart';

class ServerRepository extends BaseRepository {
  ServerRepository();

  Future<List<Servidor>> all() async {
    var result = await db.find();
    //print('ServerRepository all result $result');
    return result.map((m) => Servidor.fromMap(m as Map<String, dynamic>)).toList();
  }

  Future<Servidor> getById(String id) async {
    var result = await db.first({'id': id});
    return Servidor.fromMap(Map<String, dynamic>.from(result));
  }

  Future<Servidor> insert(Servidor server) async {
    await db.insert(server.toMap());
    //return server..id = result.toString();
    return server;
  }

  Future<Servidor> update(Servidor server) async {
    await db.update({'id': server.id}, server.toMap());
    return server;
  }

  Future<void> remove(Servidor server) async {
    await db.remove({'id': server.id});
  }

  Future<void> removeById(String id) async {
    await db.remove({'id': id});
  }

  Future<void> removeAll() async {
    await db.cleanup();
  }
}
