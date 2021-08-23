// Persist on filesystem (Flutter Mobile & Desktop)
// ignore: implementation_imports
import 'package:objectdb/src/objectdb_storage_filesystem.dart';
// ignore: implementation_imports
import 'package:objectdb/src/objectdb_storage_in_memory.dart';
import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class BaseRepository {
  static ObjectDB _db = ObjectDB(InMemoryStorage(), version: 1);

  Future<ObjectDB> get database async {
    if (_db.v == 2) return _db;

    // if _database is null we instantiate it
    _db = await initDB();
    return _db;
  }

  Future<ObjectDB> initDB() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'fsbackup.db');
    // create database instance and open
    return ObjectDB(FileSystemStorage(path), version: 2);
  }

  // cleanup the db file
  Future<void> deleteDB() async {
    _db.cleanup();
  }

  Future<dynamic> dispose() async {
    return _db.close();
  }
}
