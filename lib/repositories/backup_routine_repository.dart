import 'package:fsbackup/repositories/server_repository.dart';
import 'package:fsbackup/services/mongodb_service.dart';
import 'package:fsbackup_shared/fsbackup_shared.dart';
import 'package:mongo_dart/mongo_dart.dart';

class BackupRoutineRepository {
  final MongodbService mongo;
  DbCollection collection;
  BackupRoutineRepository(this.mongo) {
    collection = mongo.db.collection('rotinas');
  }

  Future<List<BackupRoutineModel>> all() async {
    final result = await collection.find().toList();
    var routines = result.map((m) => BackupRoutineModel.fromMap(m)).toList();

    var idsServers = <String>[];

    routines?.forEach((rotina) {
      if (rotina.servers is List) {
        rotina.servers.forEach((serv) {
          idsServers.add(serv.id);
        });
      }
    });

    if (idsServers.isNotEmpty) {
      var servers = await ServerRepository(mongo).findAllByIds(idsServers);
      if (servers is List) {
        routines?.forEach((rotina) {
          var rotinaServersIds = rotina.servers?.map((e) => e.id)?.toList();
          if (rotinaServersIds is List) {
            rotina.servers =
                servers.where((s) => rotinaServersIds.contains(s.id))?.toList();
          }
        });
      }
    }

    //print(idsServers);

    return routines;
  }

  Future<List<BackupRoutineModel>> findAllByIds(List<String> ids) async {
    final result = await collection.find({
      'id': {r'$in': ids}
    }).toList();
    return result.map((m) => BackupRoutineModel.fromMap(m)).toList();
  }

  Future<List<Map<String, dynamic>>> findAllByIdsAsMap(List<String> ids) async {
    final result = await collection.find({
      'id': {r'$in': ids}
    }).toList();
    return result;
  }

  Future<BackupRoutineModel> getById(String id) async {
    final result = await collection.findOne({'id': id});
    return BackupRoutineModel.fromMap(Map<String, dynamic>.from(result));
  }

  Future<BackupRoutineModel> insert(BackupRoutineModel server) async {
    await collection.insert(server.toMap());
    return server;
  }

  Future<BackupRoutineModel> update(BackupRoutineModel routine) async {
    await collection.update({'id': routine.id}, routine.toMap());
    return routine;
  }

  Future<void> remove(BackupRoutineModel routine) async {
    await collection.remove({'id': routine.id});
  }

  Future<void> removeById(String id) async {
    await collection.remove({'id': id});
  }
}
