import 'package:fsbackup/models/servidor.dart';

enum StartBackup { manual, agendado }

extension StartBackupToString on StartBackup {
  String get text {
    return this.toString().split('.').last;
  }
}

class RotinaBackup {
  String id;
  //lista de servidoes a serem feito backup
  List<Servidor> servidores;
  String nome;
  String diretorioDestino;
  StartBackup startBackup;
  String icon = 'assets/icons/media_file.svg';

  //extras
  dynamic status = '';
  double percent = 0;

  RotinaBackup({this.id, this.servidores, this.nome, this.diretorioDestino, this.startBackup});

  factory RotinaBackup.fromMap(Map<String, dynamic> map) {
    var s = RotinaBackup(
      id: map['id'] as String,
      nome: map['nome'],
      diretorioDestino: map['diretorioDestino'],
      startBackup: map['startBackup'].toString().contains('manual') ? StartBackup.manual : StartBackup.agendado,
    );
    if (map.containsKey('servidores')) {
      s.servidores = List<Servidor>.from(map['servidores'].map((x) => Servidor.fromMap(x)));
    }

    return s;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'nome': nome,
      'diretorioDestino': diretorioDestino,
      'startBackup': startBackup.text,
    };
    if (servidores != null) {
      map['servidores'] = servidores.map((x) => x.toMap()).toList();
    }

    return map;
  }
}
