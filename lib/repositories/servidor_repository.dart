import 'package:fsbackup/models/servidor.dart';
import 'package:fsbackup/db/local_database.dart';

class ServidorRepository {
  final LocalDatabase db = LocalDatabase();
  ServidorRepository() {
    db.collection = 'servidores';
  }

  Future<dynamic> initDB() {
    return db.initDB();
  }

  Future<List<Servidor>> all() async {
    var result = await db.find();
    return result.map((m) => Servidor.fromMap(m)).toList();
  }

  Future<Servidor> getById(String id) async {
    var result = await db.first({'id': id});
    return Servidor.fromMap(Map<String, dynamic>.from(result));
  }

  Future<Servidor> insert(Servidor server) async {
    await db.insert(server.toMap());
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
}
