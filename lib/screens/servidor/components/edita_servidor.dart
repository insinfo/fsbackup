import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/constants.dart';
import 'package:fsbackup/models/diretorio.dart';
import 'package:fsbackup/models/servidor.dart';
import 'package:fsbackup/providers/servidor_provider.dart';
import 'package:fsbackup/responsive.dart';
import 'package:fsbackup/shared/components/custom_textfield.dart';
import 'package:fsbackup/shared/validator.dart';

import 'package:uuid/uuid.dart';

class EditaServidor extends StatefulWidget {
  final Servidor server;
  EditaServidor({this.server});

  @override
  _EditaServidorState createState() => _EditaServidorState();
}

class _EditaServidorState extends State<EditaServidor> {
  final _formKey = GlobalKey<FormState>();

  var nameControl = TextEditingController();
  var hostControl = TextEditingController();
  var portControl = TextEditingController();
  var userControl = TextEditingController();
  var passControl = TextEditingController();

  List<Diretorio> diretorios = [];

  @override
  void initState() {
    super.initState();
    fillControls(widget.server);
  }

  void fillControls(Servidor model) {
    nameControl.text = widget.server == null ? '' : widget.server.nome;
    hostControl.text = widget.server == null ? '' : widget.server.host;
    portControl.text = widget.server?.port == null ? '' : widget.server.port.toString();
    userControl.text = widget.server == null ? '' : widget.server.user;
    passControl.text = widget.server == null ? '' : widget.server.password;
    diretorios.clear();
    if (widget.server == null || widget.server.directories == null || widget.server.directories.isEmpty) {
      diretorios.add(Diretorio(path: ''));
    } else {
      diretorios.addAll(widget.server.directories);
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
    model.directories = diretorios;
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
    return AlertDialog(
      scrollable: false,
      backgroundColor: secondaryColor,
      title: Text(
        widget.server == null ? 'Novo Servidor' : 'Editar Servidor',
      ),
      content: Builder(builder: (BuildContext context) {
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
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    nameControl: nameControl,
                    label: 'Nome',
                    validator: (v) {
                      if (v.isEmpty) {
                        return 'Informe o nome!';
                      } else {
                        return null;
                      }
                    },
                  ),
                  CustomTextField(
                    nameControl: hostControl, label: 'Host',
                    validator: (val) {
                      var isValid = validator.ip(val);
                      return !isValid ? 'Informe um IP valido' : null;
                    },
                    //inputFormatters: [IpAddressInputFormatter()]
                  ),
                  CustomTextField(
                      nameControl: portControl,
                      label: 'Porta',
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      validator: (v) => v.isEmpty ? 'Informe a Porta' : null),
                  CustomTextField(nameControl: userControl, label: 'Login'),
                  CustomTextField(
                    nameControl: passControl,
                    label: 'Senha',
                    isPassword: true,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text(
                      'Diretorios para backup:',
                      style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.5), fontSize: 15),
                    ),
                  ),
                  //for (var item in diretorios) DirWideget(diretorio: item),
                  for (var item in diretorios)
                    DirWideget(item, hintText: 'Digite o caminho', onRemove: () {
                      if (diretorios.length > 1) {
                        setState(() {
                          diretorios.remove(item);
                        });
                      }
                    }),
                ],
              ),
            ),
          ),
        );
      }),
      actions: <Widget>[
        TextButton(
            child: Text(
              'Add Diretorio',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              setState(() {
                diretorios.add(Diretorio(path: ''));
              });
            }),
        TextButton(
          child: Text(
            'Cancelar',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ButtonStyle(),
        ),
        ElevatedButton(
          child: Text(
            widget.server == null ? 'Add' : 'Atualizar',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              // Se o form for válido
              if (widget.server == null) {
                add();
              } else {
                edit();
              }
            } else {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Preencha corretamente o formulário!')));
            }
          },
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

class DirWideget extends StatelessWidget {
  const DirWideget(this.diretorio, {Key key, this.onRemove, this.hintText}) : super(key: key);

  final Diretorio diretorio;
  final String hintText;
  final void Function() onRemove;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(0.0),
            child: CustomTextField(
              hintText: hintText,
              //label: 'Diretorio para backup',
              initialValue: diretorio.path,
              onChanged: (v) => diretorio.path = v,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: IconButton(
            icon: Icon(Icons.delete),
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}
