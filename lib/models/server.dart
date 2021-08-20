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
    this.user,
    this.password,
    this.directories,
  });
  String id;
  String name;
  String hostName;
  int port;
  String user;
  String password;
  List<Diretorio> directories;

  String privateKey;

  Server.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    hostName = map['hostName'];
    port = map['port'];
    user = map['user'];
    password = map['password'];

    if (map.containsKey('directories') && map['directories'] is List) {
      directories = List<Diretorio>.from(map['directories'].map((x) => Diretorio.fromMap(x)));
      //directories = map['directories'];
    }

    if (map.containsKey('privateKey')) {
      privateKey = map['privateKey'];
    }
  }

  Map<String, dynamic> toMap() {
    var map = {
      'hostName': hostName,
      'port': port,
    };

    if (id != null) {
      map['id'] = id;
    }
    map['name'] = name;
    map['user'] = user;
    map['password'] = password;

    map['directories'] = directories != null ? directories.map((x) => x.toMap()).toList() : [];

    if (privateKey != null) {
      map['privateKey'] = privateKey;
    }
    return map;
  }
}
