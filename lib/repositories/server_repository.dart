import 'package:fsbackup/models/server_model.dart';

import 'package:fsbackup/services/mongodb_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ServerRepository {
  final MongodbService mongo;
  DbCollection collection;
  ServerRepository(this.mongo) {
    collection = mongo.db.collection('servidores');
  }

  Future<List<ServerModel>> all() async {
    final result = await collection.find().toList();
    return result.map((m) => ServerModel.fromMap(m)).toList();
  }

  Future<List<ServerModel>> findAllByIds(List<String> ids) async {
    final result = await collection.find({
      'id': {r'$in': ids}
    }).toList();
    return result.map((m) => ServerModel.fromMap(m)).toList();
  }

  Future<List<Map<String, dynamic>>> findAllByIdsAsMap(List<String> ids) async {
    final result = await collection.find({
      'id': {r'$in': ids}
    }).toList();
    return result;
  }

  Future<ServerModel> getById(String id) async {
    final result = await collection.findOne({'id': id});
    return ServerModel.fromMap(Map<String, dynamic>.from(result));
  }

  Future<ServerModel> insert(ServerModel server) async {
    await collection.insert(server.toMap());
    return server;
  }

  Future<ServerModel> update(ServerModel server) async {
    await collection.update({'id': server.id}, server.toMap());
    return server;
  }

  Future<void> remove(ServerModel server) async {
    await collection.remove({'id': server.id});
  }

  Future<void> removeById(String id) async {
    await collection.remove({'id': id});
  }
}
