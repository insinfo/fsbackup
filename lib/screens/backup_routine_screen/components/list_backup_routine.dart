import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/constants.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import 'package:fsbackup/providers/backup_routine_provider.dart';
import 'package:fsbackup/screens/backup_routine_screen/components/edit_backup_routine.dart';
import 'package:fsbackup/screens/backup_routine_screen/components/log_view_dialog.dart';

import 'package:fsbackup_shared/fsbackup_shared.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart'; //Add this line to multi-language-support

class ListBackupRoutine extends StatelessWidget {
  ListBackupRoutine({
    Key key,
  }) : super(key: key);

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
          SizedBox(
            width: double.infinity,
            child: ChangeNotifierProvider.value(
              value: locator<BackupRoutineProvider>(),
              builder: (context, w) => Consumer<BackupRoutineProvider>(builder: (ctx, data, child) {
                return FutureBuilder<List<BackupRoutineModel>>(
                    future: data.getAll(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.length == 0) {
                          return Center(child: Text(AppLocalizations.of(context).noItems));
                        } else if (snapshot.data.length > 0) {
                          return DataTable2(
                              columnSpacing: defaultPadding,
                              minWidth: 600,
                              columns: [
                                DataColumn(label: Text(AppLocalizations.of(context).columnName)),
                                DataColumn(label: Text(AppLocalizations.of(context).columnBackupDestination)),
                                DataColumn(label: Text(AppLocalizations.of(context).columnStartHow)),
                                DataColumn(label: Text(AppLocalizations.of(context).columnServer)),
                                DataColumn(
                                    label: Center(
                                  child: Text(AppLocalizations.of(context).columnActions, textAlign: TextAlign.center),
                                )),
                                DataColumn(label: Center(child: Text('Log', textAlign: TextAlign.center))),
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

  DataRow createItem(BackupRoutineModel routine, BuildContext ctx) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Icon(
                Icons.event_available,
                color: Colors.purpleAccent,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text('${routine.name}'),
              ),
            ],
          ),
        ),
        DataCell(Text('${CoreUtils.truncateMidleString(routine.destinationDirectory, 20)}')),
        DataCell(Text('${routine.startBackup.text}')),
        DataCell(Text('${routine.servers?.isNotEmpty == true ? routine.servers.first.name : "Sem servidor"}')),
        DataCell(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: ctx,
                    builder: (_) => EditBackupRoutine(routine: routine),
                  );
                }),
            SizedBox(width: defaultPadding + 5),
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await showDialog(
                    context: ctx,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Alert"),
                        content: Text(AppLocalizations.of(context).confirmDeletionMessage),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop(true);
                                await locator<BackupRoutineProvider>().delete(routine.id);
                              },
                              child: Text(AppLocalizations.of(context).btnDelete)),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(AppLocalizations.of(context).btnCancelar),
                          ),
                        ],
                      );
                    },
                  );
                }),
          ],
        )),
        DataCell(Center(
          child: IconButton(
              icon: Icon(Icons.visibility),
              onPressed: () {
                Navigator.of(ctx).push(MaterialPageRoute<Null>(
                    builder: (BuildContext context) {
                      return RoutineLogViewDialog(routine);
                    },
                    fullscreenDialog: true));
              }),
        ))
      ],
    );
  }
}
