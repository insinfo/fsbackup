import 'package:fsbackup/models/server_model.dart';

enum StartBackup { manual, scheduled }

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
  dynamic status = '';
  double percent = 0;

  BackupRoutineModel({this.id, this.servers, this.name, this.destinationDirectory, this.startBackup});

  factory BackupRoutineModel.fromMap(Map<String, dynamic> map) {
    var s = BackupRoutineModel(
      id: map['id'] as String,
      name: map['name'],
      destinationDirectory: map['destinationDirectory'],
      startBackup: map['startBackup'].toString().contains('manual') ? StartBackup.manual : StartBackup.scheduled,
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
    };
    if (servers != null) {
      map['servers'] = servers.map((x) => x.toMap()).toList();
    }

    return map;
  }
}
