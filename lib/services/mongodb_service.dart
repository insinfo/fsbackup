import 'dart:convert';
import 'dart:io';

import 'package:fsbackup/shared/utils/utils.dart';
import 'package:mongo_dart/mongo_dart.dart';
import "package:path/path.dart" show dirname;

class MongodbService {
  static final String _currentDir = Platform.resolvedExecutable;
  var mongoExecutableDir = '${dirname(_currentDir)}/data/flutter_assets/assets/mongodb/';
  var databaseDir = 'fsbackup/database/';
  MongodbService();
  Db db;
  Future<void> initDB() async {
    if (!(await tryConnect())) {
      //var isMongoRunning = ProcessHelper.isProcessRunning('mongod.exe');
      //await Future.delayed(Duration(minutes: 1));
      //if (!isMongoRunning) {
      //inicia o processo do mongodb
      await startMongodb();
      //}

      //cria o banco de dados
      await createDatabase();

      //abre a conexão com o banco
      await tryConnect();
    }
    return db;
  }

  Future<dynamic> dispose() {
    return db.close();
  }

  Future<bool> createDatabase() async {
    try {
      var createDbResult = await Process.run(
          '$mongoExecutableDir/mongo.exe', ['--port', '27085', 'admin', '${mongoExecutableDir}cratedb.js']);
      print('MongodbService@createDatabase $createDbResult');
      return true;
    } catch (e) {
      print('MongodbService@createDatabase $e');
      return false;
    }
  }

  Future<bool> startMongodb() async {
    try {
      var dataBaseDir = await Utils.createDirectoryIfNotExist(databaseDir);
      print(dataBaseDir);
      var mongodProcess = await Process.start('${mongoExecutableDir}mongod.exe',
          ['--dbpath', '$dataBaseDir', '--port', '27085', '--logpath', '${dataBaseDir}logs.txt']);
      mongodProcess.stdout.transform(utf8.decoder).forEach(print);
      print('MongodbService@startMongodb start');
      return true;
    } catch (e) {
      print('MongodbService@startMongodb $e');
      return false;
    }
  }

  Future<bool> tryConnect() async {
    try {
      db = Db('mongodb://localhost:27085/fsbackup');
      await db.open();
      print('MongodbService@tryConnect conectado');
      return true;
    } catch (e) {
      print('MongodbService@tryConnect erro ao conectar $e');
      return false;
    }
  }
}
