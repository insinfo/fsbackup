import 'package:flutter/material.dart';
import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/constants.dart';
import 'package:fsbackup/models/diretorio.dart';
import 'package:fsbackup/models/servidor.dart';
import 'package:fsbackup/providers/servidor_provider.dart';
import 'package:fsbackup/responsive.dart';
import 'package:fsbackup/shared/components/custom_textfield.dart';
import 'package:fsbackup/shared/text_input_formatters/ip_address_input_formatter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:uuid/uuid.dart';

class EditaServidor extends StatefulWidget {
  final Servidor server;
  EditaServidor({this.server});

  @override
  _EditaServidorState createState() => _EditaServidorState();
}

class _EditaServidorState extends State<EditaServidor> {
  var nameControl = TextEditingController();
  var hostControl = TextEditingController();
  var portControl = TextEditingController();
  var userControl = TextEditingController();
  var passControl = TextEditingController();
  var dirControl = TextEditingController();

  void fillControls(Servidor model) {
    nameControl.text = widget.server == null ? '' : widget.server.nome;
    hostControl.text = widget.server == null ? '' : widget.server.host;
    portControl.text = widget.server?.port == null ? '' : widget.server.port.toString();
    userControl.text = widget.server == null ? '' : widget.server.user;
    passControl.text = widget.server == null ? '' : widget.server.password;
    if (widget.server == null || widget.server.directories == null || widget.server.directories.isEmpty) {
      dirControl.text = '';
    } else {
      dirControl.text = widget.server.directories.first.path;
    }
  }

  void fillModel(Servidor model, bool isNew) {
    if (isNew) {
      model.id = Uuid().v1();
    }
    model.nome = nameControl.text;
    model.host = hostControl.text;
    model.port = int.tryParse(portControl.text);
    model.user = userControl.text;
    model.password = passControl.text;
    model.directories = [Diretorio(path: dirControl.text)];
  }

  void edit() async {
    fillModel(widget.server, false);
    await locator<ServidorProvider>().update(widget.server);
    Navigator.of(context).pop();
  }

  void add() async {
    var newServer = Servidor();
    fillModel(newServer, true);
    await locator<ServidorProvider>().insert(newServer);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    fillControls(widget.server);

    return AlertDialog(
      scrollable: false,
      backgroundColor: secondaryColor,
      title: Text(
        widget.server == null ? 'Novo Servidor' : 'Editar Servidor',
      ),
      content: Builder(builder: (context) {
        var height = MediaQuery.of(context).size.height;
        var width = MediaQuery.of(context).size.width;

        if (Responsive.isDesktop(context)) {
          height = height > 300 ? height * 0.5 : height - 10;
          width = width > 300 ? width * 0.6 : width - 10;
        } else {
          height = height - 10;
          width = width - 10;
        }

        return Container(
          // height: height,
          width: width,
          // constraints: BoxConstraints(minWidth: 300, maxWidth: width - 10, minHeight: 300, maxHeight: height - 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(nameControl: nameControl, label: 'Nome'),
              CustomTextField(nameControl: hostControl, label: 'Host', inputFormatters: [IpAddressInputFormatter()]),
              CustomTextField(nameControl: portControl, label: 'Porta'),
              CustomTextField(nameControl: userControl, label: 'Login'),
              CustomTextField(nameControl: passControl, label: 'Senha'),
              CustomTextField(nameControl: dirControl, label: 'Diretorio para backup')
            ],
          ),
        );
      }),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Cancelar',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            widget.server == null ? 'Add' : 'Atualizar',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: widget.server == null ? add : edit,
        )
      ],
    );
  }

  @override
  void dispose() {
    nameControl.dispose();
    super.dispose();
  }
}
