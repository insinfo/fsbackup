import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/constants.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fsbackup/models/backup_routine_model.dart';
import 'package:fsbackup/providers/fila_provider.dart';
import 'package:provider/provider.dart';

class FilaBackupWidget extends StatefulWidget {
  @override
  _FilaBackupWidgetState createState() => _FilaBackupWidgetState();
}

class _FilaBackupWidgetState extends State<FilaBackupWidget> {
  @override
  void initState() {
    super.initState();
  }

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
                                DataColumn(label: Text('Status')),
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

DataRow createItem(BackupRoutineModel rotina, BuildContext ctx) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            SvgPicture.asset(
              rotina.icon,
              height: 30,
              width: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(rotina.name),
            ),
          ],
        ),
      ),
      DataCell(Text(rotina.destinationDirectory)),
      DataCell(Text('${rotina.percent.toStringAsFixed(4)}%')),
    ],
  );
}

///
