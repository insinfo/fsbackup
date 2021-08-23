import 'dart:convert';

import 'package:fsbackup/models/diretorio.dart';

Server serverFromJson(String str) => Server.fromMap(json.decode(str));
String serverToJson(Server data) => json.encode(data.toMap());

class Server {
  Server({
    this.id,
    this.name,
    this.hostName,
    this.port,
    this.directories,
    this.user,
    this.password,
    this.privateKey,
  });
  String id;
  String name;
  String hostName;
  int port;
  String user;
  String password;
  List<Diretorio> directories;

  String privateKey;

  factory Server.fromMap(Map<String, dynamic> map) {
    var s = Server(
      id: map['_id'] as String,
      name: map['name'],
      hostName: map['hostName'],
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
    var map = {
      'id': id,
      'name': name,
      'hostName': hostName,
      'port': port,
    };

    map['user'] = user;
    map['password'] = password;
    map['directories'] = directories.map((x) => x.toMap()).toList();
    map['privateKey'] = privateKey;

    return map;
  }
}
