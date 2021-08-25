import 'package:flutter/material.dart';
import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/constants.dart';
import 'package:fsbackup/models/servidor.dart';
import 'package:fsbackup/models/tarefa_backup.dart';
import 'package:fsbackup/providers/servidor_provider.dart';
import 'package:fsbackup/providers/tarefa_provider.dart';
import 'package:fsbackup/responsive.dart';
import 'package:fsbackup/shared/components/servidor_picker.dart';
import 'package:fsbackup/shared/components/custom_textfield.dart';

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class EditaTarefa extends StatefulWidget {
  final TarefaBackup tarefa;
  EditaTarefa({this.tarefa});

  @override
  _EditaTarefaState createState() => _EditaTarefaState();
}

class _EditaTarefaState extends State<EditaTarefa> {
  var nomeControl = TextEditingController();
  var dirDestinoControl = TextEditingController();
  var dropdownValue = StartBackup.manual;
  Servidor servidor;

  void fillControls() {
    nomeControl.text = widget.tarefa == null ? '' : widget.tarefa.nome;
    dirDestinoControl.text = widget.tarefa == null ? '' : widget.tarefa.diretorioDestino;

    if (widget.tarefa != null) {
      if (widget.tarefa.startBackup != null) {
        dropdownValue = widget.tarefa.startBackup;
      }
      if (widget.tarefa.servidores != null && widget.tarefa.servidores.isNotEmpty) {
        servidor = widget.tarefa.servidores.first;
      }
    }
  }

  void fillModel(TarefaBackup model, bool isNew) {
    if (isNew) {
      model.id = Uuid().v1();
      model.startBackup = StartBackup.manual;
      model.servidores = [servidor];
    }
    model.nome = nomeControl.text;
    model.diretorioDestino = dirDestinoControl.text;
    model.startBackup = dropdownValue;
    model.servidores = model.servidores;
  }

  void edit() async {
    fillModel(widget.tarefa, false);
    await locator<TarefaProvider>().update(widget.tarefa);
    Navigator.of(context).pop();
  }

  void add() async {
    var newTarefa = TarefaBackup();
    fillModel(newTarefa, true);
    await locator<TarefaProvider>().insert(newTarefa);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    fillControls();

    return AlertDialog(
      scrollable: false,
      backgroundColor: secondaryColor,
      title: Text(
        widget.tarefa == null ? 'Nova Tarefa' : 'Editar Tarefa',
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(nameControl: nomeControl, label: 'Nome'),
              CustomTextField(nameControl: dirDestinoControl, label: 'Diretorio destino do backup'),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Text('Como iniciar:', style: TextStyle(color: Colors.white.withAlpha(150))),
                  ),
                  DropdownButton<StartBackup>(
                    value: dropdownValue,
                    items: [StartBackup.manual, StartBackup.agendado].map((opt) {
                      return DropdownMenuItem<StartBackup>(
                        value: opt,
                        child: Text(opt.text.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        dropdownValue = v;
                      });
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Servidor:', style: TextStyle(color: Colors.white.withAlpha(150))),
                  ),
                  ChangeNotifierProvider.value(
                      value: locator<ServidorProvider>(),
                      builder: (context, w) => Consumer<ServidorProvider>(builder: (ctx, data, child) {
                            return FutureBuilder<List<Servidor>>(
                                future: data.getAll(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data.length == 0) {
                                      return Center(child: Text("Não ha Servidores"));
                                    } else if (snapshot.data.length > 0) {
                                      return ServidorPicker(
                                        items: snapshot.data,
                                        initialSelection: servidor?.nome,
                                        onChanged: (v) {
                                          print('onChanged ${v.nome}');
                                          servidor = v;
                                        },
                                      );
                                    }
                                  }
                                  return Center(child: CircularProgressIndicator());
                                });
                          })),
                ],
              )
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
            widget.tarefa == null ? 'Add' : 'Atualizar',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: widget.tarefa == null ? add : edit,
        )
      ],
    );
  }

  @override
  void dispose() {
    nomeControl.dispose();
    dirDestinoControl.dispose();
    super.dispose();
  }
}
