import 'package:fsbackup_shared/src/models/server_model.dart';

enum StartBackup { manual, scheduled }

/// andamento | espera | falhou
enum RoutineStatus { progress, waiting, failed }

extension RoutineStatusToString on RoutineStatus {
  String get text {
    return this.toString().split('.').last;
  }
}

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

  /// progress/waiting/failed |  andamento/espera/falhou
  RoutineStatus status = RoutineStatus.waiting;
  double percent = 0;
  String log = '';

  /// data do ultimo backup
  DateTime lastBackup;

  /// quando fazer backup?
  String whenToBackup;

  bool compressAsZip = false;

  /// não parar backup em casa de falha em algum arquivo
  bool dontStopIfFileException = false;

  bool removeOld = true;

  /// tempo de permanencia de backups antigos
  int holdOldFilesInDays = 5;

  dynamic handleCancel;

  BackupRoutineModel(
      {this.id,
      this.servers,
      this.name,
      this.destinationDirectory,
      this.startBackup,
      this.status,
      this.percent,
      this.lastBackup,
      this.log,
      this.whenToBackup,
      this.compressAsZip,
      this.dontStopIfFileException = false,
      this.removeOld = true,
      this.holdOldFilesInDays = 5});

  static RoutineStatus statusFromString(String str) {
    if (str == null) {
      return RoutineStatus.waiting;
    } else if (str == RoutineStatus.waiting.text) {
      return RoutineStatus.waiting;
    } else if (str == RoutineStatus.failed.text) {
      return RoutineStatus.failed;
    } else if (str == RoutineStatus.progress.text) {
      return RoutineStatus.progress;
    } else {
      return RoutineStatus.waiting;
    }
  }

  BackupRoutineModel cloneWithoutHandleCancel() {
    return BackupRoutineModel(
      id: id,
      name: name,
      servers: [...servers],
      destinationDirectory: destinationDirectory,
      startBackup: startBackup,
      status: status,
      percent: percent,
      lastBackup: lastBackup,
      log: log,
      whenToBackup: whenToBackup,
      compressAsZip: compressAsZip,
      dontStopIfFileException: dontStopIfFileException,
      removeOld: removeOld,
      holdOldFilesInDays: holdOldFilesInDays,
    );
  }

  factory BackupRoutineModel.fromMap(Map<String, dynamic> map) {
    var s = BackupRoutineModel(
      id: map['id'] as String,
      name: map['name'],
      destinationDirectory: map['destinationDirectory'],
      startBackup: map['startBackup'].toString().contains('manual') ? StartBackup.manual : StartBackup.scheduled,
      status: statusFromString(map['status']),
      percent: map['percent'] is double ? map['percent'] : 0,
      lastBackup: DateTime.tryParse(map['lastBackup'].toString()),
      log: map['log'],
      whenToBackup: map['whenToBackup'],
      compressAsZip: map['compressAsZip'],
      removeOld: map.containsKey('removeOld') ? map['removeOld'] : false,
      holdOldFilesInDays: map.containsKey('holdOldFilesInDays') ? map['holdOldFilesInDays'] : 5,
      dontStopIfFileException: map['dontStopIfFileException'],
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
      'status': status.text,
      'percent': percent,
      'lastBackup': lastBackup?.toString(),
      'log': log,
      'whenToBackup': whenToBackup,
      'compressAsZip': compressAsZip,
      'dontStopIfFileException': dontStopIfFileException,
      'removeOld': removeOld,
      'holdOldFilesInDays': holdOldFilesInDays,
    };
    if (servers != null) {
      map['servers'] = servers.map((x) => x.toMap()).toList();
    }

    return map;
  }
}
