import 'dart:convert';

import 'package:fsbackup/models/file_system_object.dart';

ServerModel serverFromJson(String str) => ServerModel.fromMap(json.decode(str));
String serverToJson(ServerModel data) => json.encode(data.toMap());

class ServerModel {
  ServerModel({
    this.id,
    this.name,
    this.host,
    this.port,
    this.fileObjects,
    this.user,
    this.password,
    this.privateKey,
  });
  String id;
  String name;
  String host;
  int port;
  String user;
  String password;

  /// files or directories for backups
  List<FileSystemObject> fileObjects;
  String icon = 'assets/icons/Figma_file.svg';

  String privateKey;

  factory ServerModel.fromMap(Map<String, dynamic> map) {
    var s = ServerModel(
      id: map['id'] as String,
      name: map['name'],
      host: map['host'],
      port: map['port'],
      fileObjects: List<FileSystemObject>.from(map['fileObjects'].map((x) => FileSystemObject.fromMap(x))),
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
      'name': name,
      'host': host,
      'port': port,
    };

    map['user'] = user;
    map['password'] = password;
    map['fileObjects'] = fileObjects.map((x) => x.toMap()).toList();
    map['privateKey'] = privateKey;

    return map;
  }
}
