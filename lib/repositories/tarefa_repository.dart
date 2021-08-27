import 'package:fsbackup/models/rotina_backup.dart';
import 'package:fsbackup/db/local_database.dart';

class RotinaBackupRepository {
  final LocalDatabase db = LocalDatabase();
  RotinaBackupRepository() {
    db.collection = 'tarefas';
  }

  Future<dynamic> initDB() {
    return db.initDB();
  }

  Future<List<RotinaBackup>> all() async {
    var result = await db.find();
    return result.map((m) => RotinaBackup.fromMap(m)).toList();
  }

  Future<RotinaBackup> getById(String id) async {
    var result = await db.first({'id': id});
    return RotinaBackup.fromMap(Map<String, dynamic>.from(result));
  }

  Future<RotinaBackup> insert(RotinaBackup server) async {
    await db.insert(server.toMap());
    return server;
  }

  Future<RotinaBackup> update(RotinaBackup server) async {
    await db.update({'id': server.id}, server.toMap());
    return server;
  }

  Future<void> remove(RotinaBackup server) async {
    await db.remove({'id': server.id});
  }

  Future<void> removeById(String id) async {
    await db.remove({'id': id});
  }
}
