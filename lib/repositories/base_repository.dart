// Persist on filesystem (Flutter Mobile & Desktop)
// ignore: implementation_imports
import 'package:objectdb/src/objectdb_storage_filesystem.dart';
// ignore: implementation_imports
import 'package:objectdb/src/objectdb_storage_in_memory.dart';
import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class BaseRepository {
  ObjectDB db;

  Future<void> initializeDB() async {
    if (db == null) {
      print('BaseRepository initializeDB');

      var documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'fsbackup.db');
      // create database instance and open
      db = ObjectDB(FileSystemStorage(path));
      //await db.close();
      // await db.cleanup();
    }
  }

  // cleanup the db file
  Future<void> deleteDB() async {
    db.cleanup();
  }

  Future<dynamic> dispose() async {
    return db.close();
  }
}
