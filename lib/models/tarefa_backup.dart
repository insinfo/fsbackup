import 'package:fsbackup/models/servidor.dart';

enum StartBackup { manual, agendado }

extension StartBackupToString on StartBackup {
  String get text {
    return this.toString().split('.').last;
  }
}

class TarefaBackup {
  String id;
  //lista de servidoes a serem feito backup
  List<Servidor> servidores;
  String nome;
  String diretorioDestino;
  StartBackup startBackup = StartBackup.manual;
  String icon = 'assets/icons/menu_task.svg';

  TarefaBackup({this.id, this.servidores, this.nome, this.diretorioDestino, this.startBackup = StartBackup.manual});

  factory TarefaBackup.fromMap(Map<String, dynamic> map) {
    var s = TarefaBackup(
      id: map['id'] as String,
      nome: map['name'],
      diretorioDestino: map['diretorioDestino'],
      startBackup: map['tipoBackup'].toString().contains('manual') ? StartBackup.manual : StartBackup.agendado,
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
