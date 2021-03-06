import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/constants.dart';

import 'package:fsbackup/providers/server_provider.dart';
import 'package:fsbackup/providers/backup_routine_provider.dart';
import 'package:fsbackup/responsive.dart';

import 'package:fsbackup/shared/components/servidor_picker/servidor_picker.dart';
import 'package:fsbackup/shared/components/custom_textfield.dart';
import 'package:fsbackup_shared/fsbackup_shared.dart';
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
  var whenToBackupControl = TextEditingController();
  var dropdownValue = StartBackup.manual;
  //var holdOldFilesInDaysControl = TextEditingController();
  bool compressAsZip = false;
  bool dontStopIfFileException = false;
  int holdOldFilesInDays = 5;
  bool removeOld = true;
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
    whenToBackupControl.text = widget.routine == null ? '' : widget.routine.whenToBackup;
    server = widget.routine == null ? null : widget.routine.servers.first;
    compressAsZip = widget.routine == null ? false : widget.routine.compressAsZip;
    dontStopIfFileException = widget.routine == null ? false : widget.routine.dontStopIfFileException;
    holdOldFilesInDays = widget.routine == null ? holdOldFilesInDays : widget.routine.holdOldFilesInDays;
    removeOld = widget.routine == null ? removeOld : widget.routine.removeOld;
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
    model.whenToBackup = whenToBackupControl.text;
    model.servers = [server];
    model.compressAsZip = compressAsZip;
    model.dontStopIfFileException = dontStopIfFileException;
    model.holdOldFilesInDays = holdOldFilesInDays;
    model.removeOld = removeOld;
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
                                return Center(child: Text("N??o ha Servidores"));
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
                    }),
                  ),
                ],
              ),
              if (dropdownValue == StartBackup.scheduled)
                Container(
                  padding: EdgeInsets.only(bottom: 3),
                  width: width,
                  child: /*CronFormField(
                      initialValue: '0 18 * * *',
                      // controller: _cronController,
                      labelText: 'Schedule',
                      onChanged: (val) => print(val),
                      onSaved: (val) => print(val),
                    )*/
                      CustomTextField(
                          nameControl: whenToBackupControl,
                          hintText: 'Ex: A cada minuto: "* * * * *" ou todos os dias ??s 18h: "0 18 * * *"',
                          label: 'Quando fazer?'),
                ),
              Wrap(direction: Axis.horizontal, children: [
                //Comprimir
                Padding(
                  padding: EdgeInsets.only(right: 10, left: 20),
                  child: Text('Comprimir:', style: TextStyle(color: Colors.white.withAlpha(150))),
                ),
                Switch(
                  activeColor: Colors.pinkAccent,
                  value: compressAsZip,
                  onChanged: (value) {
                    setState(() {
                      compressAsZip = value;
                    });
                  },
                ),
                //n??o pare
                Padding(
                  padding: EdgeInsets.only(right: 10, left: 20),
                  child: Text('Ignorar falha de arquivo:', style: TextStyle(color: Colors.white.withAlpha(150))),
                ),
                Switch(
                  activeColor: Colors.pinkAccent,
                  value: dontStopIfFileException,
                  onChanged: (value) {
                    setState(() {
                      dontStopIfFileException = value;
                    });
                  },
                ),
                //holdOldFilesInDays
                Padding(
                  padding: EdgeInsets.only(right: 10, left: 20),
                  child: Text('Tempo de vida old files:', style: TextStyle(color: Colors.white.withAlpha(150))),
                ),
                Container(
                  width: 100,
                  height: 30,
                  child: CustomTextField(
                    initialValue: holdOldFilesInDays.toString(),
                    onChanged: (v) {
                      setState(() {
                        holdOldFilesInDays = int.tryParse(v);
                      });
                    },
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  ),
                ),
                //n??o pare
                Padding(
                  padding: EdgeInsets.only(right: 10, left: 20),
                  child: Text('Remover old files:', style: TextStyle(color: Colors.white.withAlpha(150))),
                ),
                Switch(
                  activeColor: Colors.pinkAccent,
                  value: removeOld,
                  onChanged: (value) {
                    setState(() {
                      removeOld = value;
                    });
                  },
                ),
              ]),
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
