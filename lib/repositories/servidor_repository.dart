import 'package:fsbackup/models/servidor.dart';

import 'package:fsbackup/services/mongodb_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ServidorRepository {
  final MongodbService mongo;
  DbCollection collection;
  ServidorRepository(this.mongo) {
    collection = mongo.db.collection('servidores');
  }

  Future<List<Servidor>> all() async {
    final result = await collection.find().toList();
    return result.map((m) => Servidor.fromMap(m)).toList();
  }

  Future<Servidor> getById(String id) async {
    final result = await collection.findOne({'id': id});
    return Servidor.fromMap(Map<String, dynamic>.from(result));
  }

  Future<Servidor> insert(Servidor server) async {
    await collection.insert(server.toMap());
    return server;
  }

  Future<Servidor> update(Servidor server) async {
    await collection.update({'id': server.id}, server.toMap());
    return server;
  }

  Future<void> remove(Servidor server) async {
    await collection.remove({'id': server.id});
  }

  Future<void> removeById(String id) async {
    await collection.remove({'id': id});
  }
}
