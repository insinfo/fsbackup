import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/constants.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import 'package:fsbackup/providers/fila_provider.dart';
import 'package:fsbackup_shared/fsbackup_shared.dart';
import 'package:provider/provider.dart';

class FilaBackupWidget extends StatefulWidget {
  @override
  _FilaBackupWidgetState createState() => _FilaBackupWidgetState();
}

class _FilaBackupWidgetState extends State<FilaBackupWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fila de backups em andamento:',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          //SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ChangeNotifierProvider.value(
              value: locator<FilaProvider>(),
              builder: (context, w) => Consumer<FilaProvider>(builder: (ctx, data, child) {
                return FutureBuilder<List<BackupRoutineModel>>(
                    future: data.getAll(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.length == 0) {
                          return Center(child: Text('Não ha Tarefas em execução!'));
                        } else if (snapshot.data.length > 0) {
                          return DataTable2(
                              columnSpacing: defaultPadding,
                              minWidth: 600,
                              columns: [
                                DataColumn(label: Text('Nome')),
                                DataColumn(label: Text('Destino')),
                                DataColumn(label: Text('%')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('')),
                                //DataColumn(label: Text('Ações')),
                              ],
                              rows: snapshot.data.map<DataRow>((server) => createItem(server, ctx)).toList());
                        }
                      }
                      return Center(child: CircularProgressIndicator());
                    });
              }),
            ),
          ),
        ],
      ),
    );
  }
}

DataRow createItem(BackupRoutineModel routine, BuildContext ctx) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            Icon(
              Icons.access_time,
              color: Colors.blueAccent,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(routine.name),
            ),
          ],
        ),
      ),
      DataCell(Text('${CoreUtils.truncateMidleString(routine.destinationDirectory, 20)}')),
      DataCell(Text('${routine.percent.toStringAsFixed(2)}%')),
      DataCell(Text('${routine.status.text}')),
      DataCell(
        routine.status == RoutineStatus.progress
            ? SizedBox(
                height: 20,
                width: 20,
                child: /* Loading(
                    indicator: BallPulseIndicator(),
                    size: 50.0,
                    color: Colors.amber)*/
                    CircularProgressIndicator(),
                /* Icon(
                  Icons.timelapse,
                  color: Colors.amber,
                ),*/
              )
            : routine.status == RoutineStatus.failed
                ? Icon(
                    Icons.error,
                    color: Colors.red,
                  )
                : Icon(
                    Icons.hourglass_empty,
                    color: Colors.white,
                  ),
      ),
      /* DataCell(Row(children: [
        //ações
      ])),*/
    ],
  );
}

///
