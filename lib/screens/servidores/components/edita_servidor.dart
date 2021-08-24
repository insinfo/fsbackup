import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fsbackup/models/diretorio.dart';
import 'package:fsbackup/models/servidor.dart';
import 'package:fsbackup/providers/servidor_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class EditaServidor extends StatefulWidget {
  final Servidor server;
  EditaServidor({this.server});

  @override
  _EditaServidorState createState() => _EditaServidorState();
}

class _EditaServidorState extends State<EditaServidor> {
  var nameController = TextEditingController();

  void edit() async {
    widget.server.name = nameController.text;
    print('edit');
    await Provider.of<ServidorProvider>(context, listen: false).update(widget.server);
    Navigator.of(context).pop();
  }

  void add() async {
    print('add');
    var newServer = Servidor(
        id: Uuid().v4(),
        name: nameController.text,
        hostName: '192.168.133.13',
        port: 22,
        user: 'isaque.neves',
        password: '123',
        directories: [Diretorio(path: '/var/www/dart')]);
    await Provider.of<ServidorProvider>(context, listen: false).insert(newServer);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    nameController.text = widget.server == null ? '' : widget.server.name;
    return AlertDialog(
      title: Text(
        widget.server == null ? 'Novo Servidor' : 'Editar Servidor',
        style: TextStyle(color: Colors.blue[400]),
      ),
      content: TextField(
        controller: nameController,
        autofocus: true,
        cursorColor: Colors.blue[400],
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue[400],
            ),
          ),
          focusColor: Colors.blue[400],
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            color: Colors.blue[400],
          )),
          hintText: 'Nome',
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Cancelar',
            style: TextStyle(color: Colors.grey),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text(
            widget.server == null ? 'Add' : 'Atualizar',
            style: TextStyle(color: Colors.blue[400]),
          ),
          onPressed: widget.server == null ? add : edit,
        )
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
