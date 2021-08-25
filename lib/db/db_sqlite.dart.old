/*import 'dart:io';
import 'dart:math';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fsbackup/models/server.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'fsbackup.db');
    /*  int id;
  String name;
  String hostName;
  int port;
  String user;
  String password;
  List<Directory> directories; */
    return await openDatabase(path, version: 1, onOpen: (db) {}, onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE Server ('
          'id INTEGER PRIMARY KEY,'
          'name TEXT,'
          'hostName TEXT,'
          'port INTEGER,'
          'user TEXT,'
          'password TEXT,'
          'privateKey TEXT,'
          ')');
      await db.execute('CREATE TABLE Directory ('
          'path TEXT,'
          'id INTEGER,'
          'serverId INTEGER,'
          'FOREIGN KEY (serverId) REFERENCES Server(id)'
          ')');
    });
  }

  Future<List<Server>> getAllServers() async {
    final db = await database;
    var results = await db.query('Server');
    var servers = results.map((e) => e.map((key, value) => MapEntry(key, value as dynamic))).toList();
    if (servers.isEmpty) return [];
    for (int i = 0; i < servers.length; i++) {
      servers[i]['directories'] = await db.query('Directory', where: 'serverId = ?', whereArgs: [servers[i]['id']]);
    }
    return servers.map((c) => Server.fromMap(c)).toList();
  }

  Future<dynamic> getServer(int id) async {
    final db = await database;
    var targetMaps = await db.query('Server', where: 'id = ?', whereArgs: [id]);
    if (targetMaps.isEmpty) return Null;
    var targetMap = targetMaps[0].map((key, value) => MapEntry(key, value as dynamic));
    var hostMaps = await db.query('Directory', where: 'serverId = ?', whereArgs: [id]);
    targetMap['directories'] = hostMaps;
    return Server.fromMap(targetMap);
  }

  Future<int> newServer(Server server) async {
    server.id = new Random().nextInt(100000);
    final db = await database;
    Map<String, dynamic> newT = server.toMap();
    List<dynamic> directories = newT.remove('directories');
    await db.insert('Server', newT);
    directories = directories.map((e) {
      e['serverId'] = server.id;
      return e;
    }).toList();
    for (int i = 0; i < directories.length; i++) {
      await db.insert('Directory', directories[i]);
    }
    return server.id;
  }

  Future<void> updateServer(Server updatedTarget) async {
    final db = await database;
    var updatedT = updatedTarget.toMap();
    var hosts = updatedT.remove('hosts');
    await db.update('Server', updatedT, where: 'id = ?', whereArgs: [updatedTarget.id]);
    await db.delete('Directory', where: 'serverId = ?', whereArgs: [updatedTarget.id]);
    hosts = hosts.map((e) {
      e['serverId'] = updatedTarget.id;
      return e;
    }).toList();
    for (int i = 0; i < hosts.length; i++) {
      await db.insert('Directory', hosts[i]);
    }
    return;
  }

  Future<void> deleteServer(int id) async {
    final db = await database;
    await db.delete('Directory', where: 'serverId = ?', whereArgs: [id]);
    await db.delete('Server', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllServers() async {
    final db = await database;
    await db.delete('Directory');
    await db.delete('Server');
  }

  Future<void> deleteDB() async {
    deleteDatabase(join((await getApplicationDocumentsDirectory()).path, 'fsbackup.db'));
  }
}
*/
