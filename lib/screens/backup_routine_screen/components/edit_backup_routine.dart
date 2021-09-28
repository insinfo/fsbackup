import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/constants.dart';
import 'package:fsbackup/models/server_model.dart';
import 'package:fsbackup/models/backup_routine_model.dart';
import 'package:fsbackup/providers/server_provider.dart';
import 'package:fsbackup/providers/backup_routine_provider.dart';
import 'package:fsbackup/responsive.dart';
import 'package:fsbackup/shared/components/servidor_picker/servidor_picker.dart';
import 'package:fsbackup/shared/components/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart'; //Add this line to multi-language-support

class EditBackupRoutine extends StatefulWidget {
  final BackupRoutineModel routine;
  EditBackupRoutine({this.routine});

  @override
  _EditBackupRoutineState createState() => _EditBackupRoutineState();
}

class _EditBackupRoutineState extends State<EditBackupRoutine> {
  var nomeControl = TextEditingController();
  var dirDestinoControl = TextEditingController();
  var dropdownValue = StartBackup.manual;
  ServerModel server;

  @override
  void initState() {
    super.initState();
    fillControls();
  }

  void fillControls() {
    nomeControl.text = widget.routine == null ? '' : widget.routine.name;
    dirDestinoControl.text = widget.routine == null ? '' : widget.routine.destinationDirectory;
    dropdownValue = widget.routine == null ? StartBackup.manual : widget.routine.startBackup;
    server = widget.routine == null ? null : widget.routine.servers.first;
    /*if (widget.rotina != null) {
      if (widget.rotina.servidores != null && widget.rotina.servidores.isNotEmpty) {
        servidor = widget.rotina.servidores.first;
      }
    }*/
  }

  void fillModel(BackupRoutineModel model, bool isNew) {
    if (isNew) {
      model.id = Uuid().v1();
      //model.servidores = [servidor];
    }
    model.name = nomeControl.text;
    model.destinationDirectory = dirDestinoControl.text;
    model.startBackup = dropdownValue;
    model.servers = [server];
  }

  void edit() async {
    fillModel(widget.routine, false);
    await locator<BackupRoutineProvider>().update(widget.routine);
    Navigator.of(context).pop();
  }

  void add() async {
    var newRotina = BackupRoutineModel();
    fillModel(newRotina, true);
    await locator<BackupRoutineProvider>().insert(newRotina);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: false,
      backgroundColor: secondaryColor,
      title: Text(
        widget.routine == null ? 'Nova Rotina' : 'Editar Rotina',
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
              CustomTextField(nameControl: nomeControl, label: AppLocalizations.of(context).columnName),
              CustomTextField(
                nameControl: dirDestinoControl,
                label: 'Diretorio destino do backup',
                onTap: () async {
                  /*var pathDocuments = Platform.isWindows ? Directory('c:\\') : await getApplicationDocumentsDirectory();
                  String path = await FilesystemPicker.open(
                      title: pathDocuments.path, //'Selecione diretorio destino',
                      context: context,
                      rootDirectory: pathDocuments,
                      fsType: FilesystemType.folder,
                      pickText: 'Selecione',
                      folderIconColor: Colors.teal);*/

                  var path = await FilePicker.platform.getDirectoryPath();
                  if (path != null) {
                    setState(() => dirDestinoControl.text = path);
                  }
                },
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Text('Como iniciar:', style: TextStyle(color: Colors.white.withAlpha(150))),
                  ),
                  DropdownButton<StartBackup>(
                    value: dropdownValue,
                    items: [StartBackup.manual, StartBackup.scheduled].map((opt) {
                      return DropdownMenuItem<StartBackup>(
                        value: opt,
                        child: Text(opt.text.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        dropdownValue = v;
                        print('DropdownButton onChanged ${dropdownValue.text}');
                      });
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Servidor:', style: TextStyle(color: Colors.white.withAlpha(150))),
                  ),
                  ChangeNotifierProvider.value(
                      value: locator<ServerProvider>(),
                      builder: (context, w) => Consumer<ServerProvider>(builder: (ctx, data, child) {
                            return FutureBuilder<List<ServerModel>>(
                                future: data.getAll(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data.length == 0) {
                                      return Center(child: Text("Não ha Servidores"));
                                    } else if (snapshot.data.length > 0) {
                                      // servidor = snapshot.data.first;
                                      return ServidorPicker(
                                        items: snapshot.data,
                                        initialSelection: server?.name,
                                        onChanged: (v) {
                                          print('onChanged ${v.name}');
                                          server = v;
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
            widget.routine == null ? 'Add' : 'Atualizar',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: widget.routine == null ? add : edit,
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
