import 'package:fsbackup/models/rotina_backup.dart';

import 'package:fsbackup/services/mongodb_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class RotinaBackupRepository {
  final MongodbService mongo;
  DbCollection collection;
  RotinaBackupRepository(this.mongo) {
    collection = mongo.db.collection('rotinas');
  }

  Future<List<RotinaBackup>> all() async {
    final result = await collection.find().toList();
    return result.map((m) => RotinaBackup.fromMap(m)).toList();
  }

  Future<RotinaBackup> getById(String id) async {
    final result = await collection.findOne({'id': id});
    return RotinaBackup.fromMap(Map<String, dynamic>.from(result));
  }

  Future<RotinaBackup> insert(RotinaBackup server) async {
    await collection.insert(server.toMap());
    return server;
  }

  Future<RotinaBackup> update(RotinaBackup server) async {
    await collection.update({'id': server.id}, server.toMap());
    return server;
  }

  Future<void> remove(RotinaBackup server) async {
    await collection.remove({'id': server.id});
  }

  Future<void> removeById(String id) async {
    await collection.remove({'id': id});
  }
}
