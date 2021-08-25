import 'package:fsbackup/models/tarefa_backup.dart';
import 'package:fsbackup/db/local_database.dart';

class TarefaRepository {
  final LocalDatabase db = LocalDatabase();
  TarefaRepository() {
    db.collection = 'tarefas';
  }

  Future<dynamic> initDB() {
    return db.initDB();
  }

  Future<List<TarefaBackup>> all() async {
    var result = await db.find();
    return result.map((m) => TarefaBackup.fromMap(m)).toList();
  }

  Future<TarefaBackup> getById(String id) async {
    var result = await db.first({'id': id});
    return TarefaBackup.fromMap(Map<String, dynamic>.from(result));
  }

  Future<TarefaBackup> insert(TarefaBackup server) async {
    await db.insert(server.toMap());
    return server;
  }

  Future<TarefaBackup> update(TarefaBackup server) async {
    await db.update({'id': server.id}, server.toMap());
    return server;
  }

  Future<void> remove(TarefaBackup server) async {
    await db.remove({'id': server.id});
  }

  Future<void> removeById(String id) async {
    await db.remove({'id': id});
  }
}
