import 'package:fsbackup_shared/src/models/server_model.dart';

enum StartBackup { manual, scheduled }

/// andamento | espera | falhou
enum RoutineStatus { progress, waiting, failed }

extension StartBackupToString on StartBackup {
  String get text {
    return this.toString().split('.').last;
  }
}

class BackupRoutineModel {
  String id;
  //lista de servidoes a serem feito backup
  List<ServerModel> servers;
  String name;

  /// diretorio de destino de backups
  String destinationDirectory;
  StartBackup startBackup;
  String icon = 'assets/icons/media_file.svg';

  //extras
  String status = 'waiting'; //progress, waiting, failed  andamento/espera/falhou
  double percent = 0;
  String log = '';
  DateTime lastBackup;

  BackupRoutineModel({
    this.id,
    this.servers,
    this.name,
    this.destinationDirectory,
    this.startBackup,
    this.status,
    this.percent,
    this.lastBackup,
    this.log,
  });

  factory BackupRoutineModel.fromMap(Map<String, dynamic> map) {
    var s = BackupRoutineModel(
      id: map['id'] as String,
      name: map['name'],
      destinationDirectory: map['destinationDirectory'],
      startBackup: map['startBackup'].toString().contains('manual') ? StartBackup.manual : StartBackup.scheduled,
      status: map['status'],
      percent: map['percent'] is double ? map['percent'] : 0,
      lastBackup: DateTime.tryParse(map['lastBackup'].toString()),
      log: map['log'],
    );
    if (map.containsKey('servers')) {
      s.servers = List<ServerModel>.from(map['servers'].map((x) => ServerModel.fromMap(x)));
    }

    return s;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'destinationDirectory': destinationDirectory,
      'startBackup': startBackup.text,
      'status': status,
      'percent': percent,
      'lastBackup': lastBackup?.toString(),
      'log': log,
    };
    if (servers != null) {
      map['servers'] = servers.map((x) => x.toMap()).toList();
    }

    return map;
  }
}
