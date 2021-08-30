import 'dart:convert';
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import "package:path/path.dart" show dirname;

class MongodbService {
  MongodbService();
  Db db;
  Future<void> initDB() async {
    //instalar mongodb e  checar se esta em execução
    //var result = await Process.run('grep', ['-i', 'main', 'test.dart']);
    //var current = Platform.script.path;
    //var current = Directory.current.path;
    //Este é o caminho absoluto, com todos os links simbólicos resolvidos, para o executável usado para executar o script.
    var currentDir = Platform.resolvedExecutable;
    var mongoDir = '${dirname(currentDir)}/data/flutter_assets/assets/mongodb/';
    //print('MongodbService $mongoDir');
    //"C:\Program Files\MongoDB\Server\4.4\bin\mongod.exe" --config "C:\Program Files\MongoDB\Server\4.4\bin\mongod.cfg" --service
    // mongod.exe --dbpath D:\MyDartProjects\fsbackup\build\windows\runner\Debug\data\flutter_assets\assets\mongodb\ --port 27085 --logpath D:\MyDartProjects\fsbackup\build\windows\runner\Debug\data\flutter_assets\assets\mongodb\log
    //inicia o processo do mongodb
    var mongodProcess = await Process.start(
        '${mongoDir}mongod.exe', ['--dbpath', '$mongoDir', '--port', '27085', '--logpath', '${mongoDir}logs.txt']);
    mongodProcess.stdout.transform(utf8.decoder).forEach(print);
    //cria o banco de dados
    var createDbResult =
        await Process.run('$mongoDir/mongo.exe', ['--port', '27085', 'admin', '${mongoDir}cratedb.js']);
    print('MongodbService ${createDbResult.stdout}');
    //abre a conexão com o banco

    db = Db('mongodb://localhost:27085/fsbackup');
    await db.open();
    //tasklist /fi "ImageName eq mongod.exe" /fo csv 2>NUL | find /I "mongod.exe">NUL | if "%ERRORLEVEL%"=="0" echo running
    //await db.collection('user').insert({'nome': 'isaque'});
    return db;
  }

  Future<dynamic> dispose() {
    return db.close();
  }
}
