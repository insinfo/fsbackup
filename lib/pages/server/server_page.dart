import 'package:flutter/material.dart';
import 'package:fsbackup/models/diretorio.dart';
import 'package:fsbackup/models/server.dart';
import 'package:fsbackup/blocs/server_bloc.dart';
//import 'package:fsbackup/targetConnector.dart';

class ServerPage extends StatefulWidget {
  final Server existingServer;
  ServerPage({Key key, this.existingServer}) : super(key: key);

  @override
  _ServerPageState createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  Server server;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final hostNameController = TextEditingController();
  final portController = TextEditingController();
  List<Map<String, TextEditingController>> directoryControllers = <Map<String, TextEditingController>>[];

  bool disabled = false;

  Server getServerFromForm() {
    return new Server(
        id: this.server.id,
        name: nameController.text.trim(),
        user: usernameController.text.trim(),
        password: passwordController.text.trim(),
        hostName: hostNameController.text.trim(),
        port: int.tryParse(portController.text.trim()),
        directories: directoryControllers.map((e) => new Diretorio(path: e['path'].text.trim(), id: '1')).toList());
  }

  bool isFormValid() {
    if (_formKey.currentState == null) return false;
    return _formKey.currentState.validate() && this.directoryControllers.length > 0;
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    hostNameController.dispose();
    portController.dispose();
    directoryControllers.forEach((controller) {
      controller['path'].dispose();
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingServer != null)
      this.server = widget.existingServer;
    else
      this.server = Server();

    this.nameController.text = this.server.name != null ? this.server.name : '';
    this.usernameController.text = this.server.user != null ? this.server.user : '';
    this.passwordController.text = this.server.password != null ? this.server.password : '';
    this.hostNameController.text = this.server.privateKey != null ? this.server.privateKey : '';
    this.portController.text = this.server.port != null ? this.server.port.toString() : '';
    if (this.server.directories == null) this.server.directories = <Diretorio>[];
    this.server.directories.forEach((host) {
      this.directoryControllers.add({
        'path': new TextEditingController(text: host.path),
      });
    });
    if (this.directoryControllers.length == 0)
      this.directoryControllers.add({'path': new TextEditingController(text: '')});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FSBackup  |  ${server.id != null ? "Edit" : "Add"} Server'),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth, minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(mainAxisSize: MainAxisSize.max, children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            enabled: !this.disabled,
                            decoration: InputDecoration(labelText: 'Nome do Servidor'),
                            controller: nameController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Por favor insira um nome';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            enabled: !this.disabled,
                            decoration: InputDecoration(labelText: 'Username'),
                            controller: usernameController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Por favor coloque um nome de usuário';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            enabled: !this.disabled,
                            obscureText: true,
                            decoration: InputDecoration(labelText: 'Password'),
                            controller: passwordController,
                            autocorrect: false,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Por favor insira uma senha';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            enabled: !this.disabled,
                            decoration: InputDecoration(labelText: 'Host'),
                            controller: hostNameController,
                            autocorrect: false,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Por favor insira o IP ou DNS';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            enabled: !this.disabled,
                            decoration: InputDecoration(labelText: 'Porta'),
                            controller: portController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Por favor, insira uma porta';
                              }
                              return null;
                            },
                          ),
                          Column(
                              children: this.directoryControllers.map((e) {
                            return Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    enabled: !this.disabled,
                                    decoration: InputDecoration(labelText: 'Diretório'),
                                    controller: e['directory'],
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Por favor, insira um diretório';
                                      }
                                      /*if (!value.contains('.')) {
                                        return 'Please enter a valid URL or IP';
                                      }*/
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            );
                          }).toList()),
                          SizedBox(
                            height: 20,
                            width: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 1,
                                width: 1,
                              ),
                              Row(
                                children: [
                                  Visibility(
                                      visible: this.directoryControllers.length > 1,
                                      child: ElevatedButton(
                                        //TextButton //FlatButton
                                        onPressed: this.disabled
                                            ? null
                                            : () {
                                                setState(() {
                                                  this.directoryControllers.removeLast();
                                                });
                                              },
                                        child: Text('Remover diretorio'),
                                      )),
                                  Visibility(
                                    visible: this.directoryControllers.length <= 1,
                                    child: ElevatedButton(
                                      onPressed: this.disabled
                                          ? null
                                          : () {
                                              setState(() {
                                                this.directoryControllers.add({
                                                  'path': new TextEditingController(),
                                                  //'port': new TextEditingController()
                                                });
                                              });
                                            },
                                      child: Text('Add Diretorio'),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: this.disabled
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          child: Text('Cancel'),
                        ),
                        Visibility(
                          visible: widget.existingServer != null,
                          child: ElevatedButton(
                            onPressed: this.disabled
                                ? null
                                : () async {
                                    var res = await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Delete'),
                                            content: Text('Deletar este servidor?'),
                                            actions: [
                                              ElevatedButton(
                                                child: Text('Cancelar'),
                                                onPressed: () {
                                                  Navigator.of(context).pop(false);
                                                },
                                              ),
                                              ElevatedButton(
                                                child: Text('Deletar'),
                                                onPressed: () {
                                                  Navigator.of(context).pop(true);
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                    if (res && widget.existingServer != null) {
                                      await serverBloc.delete(widget.existingServer.id);
                                      Navigator.pop(context);
                                    }
                                  },
                            child: Text(
                              'Deletar',
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: this.disabled
                              ? null
                              : () async {
                                  /*if (isFormValid()) {
                                    setState(() {
                                      this.disabled = true;
                                    });
                                    try {
                                      int hostIndex = await new TargetConnector().testConnection(getTargetFromForm());
                                      Scaffold.of(context).showSnackBar(SnackBar(
                                          content: Text(target.hosts.length > 1
                                              ? 'Connection Successful on ${target.hosts[hostIndex].hostName}.'
                                              : 'Connection Successful.')));
                                    } catch (err) {
                                      Scaffold.of(context).showSnackBar(SnackBar(content: Text(err)));
                                    }
                                    setState(() {
                                      this.disabled = false;
                                    });
                                  }*/
                                },
                          child: Text('Testar conexão'),
                        ),
                        ElevatedButton(
                          onPressed: this.disabled
                              ? null
                              : () async {
                                  if (isFormValid()) {
                                    setState(() {
                                      this.disabled = true;
                                    });
                                    if (this.server.id != null) {
                                      await serverBloc.edit(getServerFromForm());
                                    } else {
                                      await serverBloc.add(getServerFromForm());
                                    }
                                    setState(() {
                                      this.disabled = false;
                                    });
                                    Navigator.pop(context);
                                  }
                                },
                          child: Text('Save'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                      width: 20,
                    ),
                  ]),
                )));
      }),
    );
  }
}
