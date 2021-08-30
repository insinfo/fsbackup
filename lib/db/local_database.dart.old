// Persist on filesystem (Flutter Mobile & Desktop)
// ignore: implementation_imports
import 'package:objectdb/src/objectdb_storage_filesystem.dart';

import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class LocalDatabase {
  ObjectDB db;

  String collection = '';

  LocalDatabase();

  Future<ObjectDB> initDB() async {
    if (db == null) {
      print('LocalDatabase initDB $collection');
      var documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, '${collection?.trim()?.toLowerCase()}_fsbackup.db');
      // create database instance and open
      db = ObjectDB(FileSystemStorage(path));
    }
    return db;
  }

  Future<List<Map<dynamic, dynamic>>> find([Map<dynamic, dynamic> query = const {}]) {
    return db.find(query);
  }

  Future<Map<dynamic, dynamic>> first([Map<dynamic, dynamic> query = const {}]) {
    return db.first(query);
  }

  Future<ObjectId> insert(Map<dynamic, dynamic> doc) {
    return db.insert(doc);
  }

  Future<int> update(Map<dynamic, dynamic> query, Map<dynamic, dynamic> changes) {
    return db.update(query, changes);
  }

  Future<int> remove(Map<dynamic, dynamic> query) async {
    return db.remove(query);
  }

  // cleanup the db file
  Future<dynamic> deleteDB() {
    return db.cleanup();
  }

  Future<dynamic> dispose() {
    return db.close();
  }
}
