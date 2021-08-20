// Persist on filesystem (Flutter Mobile & Desktop)
// ignore: implementation_imports
import 'package:objectdb/src/objectdb_storage_filesystem.dart';
import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class BaseRepository {
  static ObjectDB _db;

  Future<ObjectDB> get database async {
    if (_db != null) return _db;

    // if _database is null we instantiate it
    _db = await initDB();
    return _db;
  }

  Future<dynamic> initDB() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'fsbackup.db');
    // create database instance and open
    return ObjectDB(FileSystemStorage(path));
  }

  // cleanup the db file
  Future<void> deleteDB() async {
    _db.cleanup();
  }

  Future<dynamic> dispose() async {
    return _db.close();
  }
}
