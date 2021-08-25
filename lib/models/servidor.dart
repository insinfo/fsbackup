import 'dart:convert';

import 'package:fsbackup/models/diretorio.dart';

Servidor serverFromJson(String str) => Servidor.fromMap(json.decode(str));
String serverToJson(Servidor data) => json.encode(data.toMap());

class Servidor {
  Servidor({
    this.id,
    this.nome,
    this.host,
    this.port,
    this.directories,
    this.user,
    this.password,
    this.privateKey,
  });
  String id;
  String nome;
  String host;
  int port;
  String user;
  String password;
  List<Diretorio> directories;
  String icon = 'assets/icons/Figma_file.svg';

  String privateKey;

  factory Servidor.fromMap(Map<String, dynamic> map) {
    var s = Servidor(
      id: map['id'] as String,
      nome: map['nome'],
      host: map['host'],
      port: map['port'],
      directories: List<Diretorio>.from(map['directories'].map((x) => Diretorio.fromMap(x))),
    );

    if (map.containsKey('user')) {
      s.user = map['user'];
    }
    if (map.containsKey('password')) {
      s.password = map['password'];
    }

    if (map.containsKey('privateKey')) {
      s.privateKey = map['privateKey'];
    }

    return s;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'nome': nome,
      'host': host,
      'port': port,
    };

    map['user'] = user;
    map['password'] = password;
    map['directories'] = directories.map((x) => x.toMap()).toList();
    map['privateKey'] = privateKey;

    return map;
  }
}
