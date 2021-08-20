import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fsbackup/models/server.dart';

class ProcessPage extends StatefulWidget {
  final Server server;
  final GlobalKey<ScaffoldState> scaffoldKey;
  ProcessPage({Key key, this.server, this.scaffoldKey}) : super(key: key);

  @override
  _ProcessPageState createState() => _ProcessPageState();
}

class _ProcessPageState extends State<ProcessPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('FSBackup  |  Process'),
        ),
        body: Center(
          child: Text('Process'),
        ));
  }
}
