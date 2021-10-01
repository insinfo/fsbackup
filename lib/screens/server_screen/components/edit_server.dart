import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/constants.dart';

import 'package:fsbackup/providers/server_provider.dart';
import 'package:fsbackup/responsive.dart';
import 'package:fsbackup/shared/components/custom_textfield.dart';
import 'package:fsbackup_shared/fsbackup_shared.dart';

import 'package:libssh_binding/libssh_binding.dart';
import 'package:sftp_file_picker/sftp_file_picker.dart';

import 'package:uuid/uuid.dart';

class EditServer extends StatefulWidget {
  final ServerModel server;
  EditServer({this.server});

  @override
  _EditServerState createState() => _EditServerState();
}

class _EditServerState extends State<EditServer> {
  final _formKey = GlobalKey<FormState>();

  var nameControl = TextEditingController();
  var hostControl = TextEditingController();
  var portControl = TextEditingController();
  var userControl = TextEditingController();
  var passControl = TextEditingController();

  List<DirectoryItem> fileObjects = [];

  LibsshWrapper libssh;

  @override
  void initState() {
    super.initState();
    fillControls(widget.server);
  }

  void fillControls(ServerModel model) {
    nameControl.text = widget.server == null ? '' : widget.server.name;
    hostControl.text = widget.server == null ? '' : widget.server.host;
    portControl.text =
        widget.server?.port == null ? '' : widget.server.port.toString();
    userControl.text = widget.server == null ? '' : widget.server.user;
    passControl.text = widget.server == null ? '' : widget.server.password;
    fileObjects.clear();
    if (widget.server == null ||
        widget.server.fileObjects == null ||
        widget.server.fileObjects.isEmpty) {
      //fileObjects.add(FileSystemObject(path: ''));
    } else {
      fileObjects.addAll(widget.server.fileObjects);
    }
  }

  void fillModel(ServerModel model, bool isNew) {
    if (isNew) {
      model.id = Uuid().v1();
    }
    model.name = nameControl.text;
    model.host = hostControl.text;
    model.port = int.tryParse(portControl.text);
    model.user = userControl.text;
    model.password = passControl.text;
    model.fileObjects = fileObjects;
  }

  void edit() async {
    fillModel(widget.server, false);
    await locator<ServerProvider>().update(widget.server);
    Navigator.of(context).pop();
  }

  void add() async {
    var newServer = ServerModel();
    fillModel(newServer, true);
    await locator<ServerProvider>().insert(newServer);
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
                      var isValid = regexValidators.ip(val);
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
                  CustomTextField(
                    nameControl: userControl,
                    label: 'Login',
                    validator: (v) => v.isEmpty ? 'Informe a Login' : null,
                  ),
                  CustomTextField(
                    nameControl: passControl,
                    label: 'Senha',
                    isPassword: true,
                    validator: (v) => v.isEmpty ? 'Informe a Senha' : null,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text(
                      'Diretorios/Arquivos para backup:',
                      style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.5),
                          fontSize: 15),
                    ),
                  ),
                  //for (var item in diretorios) DirWideget(diretorio: item),
                  //for (var item in fileObjects)
                  ...fileObjects
                      .map((i) => dirWideget(i, hintText: 'Digite o caminho'))
                      .toList()
                ],
              ),
            ),
          ),
        );
      }),
      actions: <Widget>[
        TextButton(
            child: Text(
              'Add Diretorio|Arquivo',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                try {
                  libssh = LibsshWrapper.fromOptions(LibssOptions(
                    hostControl.text,
                    username: userControl.text,
                    password: passControl.text,
                    port: int.tryParse(portControl.text),
                  ));
                  libssh.connect();
                  var fileOrDir = await SftpFilePicker.open(
                    libsshWrapper: libssh,
                    title: 'Lista de arquivos: ${hostControl.text}',
                    context: context,
                    fsType: FilesystemType.all,
                    pickText: 'Selecione',
                    folderIconColor: Colors.yellow,
                  );
                  //print('EditServerWidget $path');
                  if (fileOrDir != null) {
                    setState(() {
                      fileObjects.add(fileOrDir);
                    });
                  }
                } catch (e, s) {
                  print('EditServerWidget@ Add Diretorio onPressed $e $s');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Erro ao se conectar com o servidor!')));
                } finally {
                  libssh.dispose();
                }
              }
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
              if (fileObjects.isNotEmpty) {
                // Se o form for válido
                if (widget.server == null) {
                  add();
                } else {
                  edit();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Selecione pelo menos um diretorio ou arquivo para backup!')));
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Preencha corretamente o formulário!')));
            }
          },
        )
      ],
    );
  }

  Widget dirWideget(DirectoryItem fileObject, {String hintText}) {
    var tec = TextEditingController();
    tec.text = fileObject.path;
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
              nameControl: tec,
              hintText: hintText,
              onChanged: (v) => fileObject.path = v,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              if (fileObjects.length > 1) {
                fileObjects.remove(fileObject);
                setState(() {});
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameControl.dispose();
    super.dispose();
  }
}
