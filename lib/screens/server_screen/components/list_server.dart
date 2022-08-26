import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/constants.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import 'package:fsbackup/providers/server_provider.dart';
import 'package:fsbackup/screens/server_screen/components/edit_server.dart';
import 'package:fsbackup_shared/fsbackup_shared.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart'; //Add this line to multi-language-support

class ListServer extends StatefulWidget {
  ListServer({Key key}) : super(key: key);

  @override
  State<ListServer> createState() => _ListServerState();
}

class _ListServerState extends State<ListServer> {
  String mensagemDelete = '';

  @override
  Widget build(BuildContext context) {
    mensagemDelete = AppLocalizations.of(context).confirmDeletionMessage;
    return Container(
      // height: 550,
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: ChangeNotifierProvider.value(
        value: locator<ServerProvider>(),
        builder: (context, w) => Consumer<ServerProvider>(builder: (ctx, data, child) {
          return FutureBuilder<List<ServerModel>>(
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
                          DataColumn(label: Text(AppLocalizations.of(context).columnHost)),
                          DataColumn(label: Text(AppLocalizations.of(context).columnPort)),
                          DataColumn(
                              label: Center(
                            child: Text(
                              AppLocalizations.of(context).columnActions,
                              textAlign: TextAlign.center,
                            ),
                          )),
                        ],
                        rows: snapshot.data.map<DataRow>((server) => servidorDataRow(server, ctx)).toList());
                  }
                }
                return Center(child: CircularProgressIndicator());
              });
        }),
      ),
    );
  }

  DataRow servidorDataRow(ServerModel server, BuildContext ctx) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Icon(
                Icons.dns,
                color: Colors.pinkAccent,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(server.name == null ? '' : server.name),
              ),
            ],
          ),
        ),
        DataCell(Text('${server.host}')),
        DataCell(Text('${server.port}')),
        DataCell(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: ctx,
                    builder: (_) => EditServer(server: server),
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
                        content: Text(mensagemDelete),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () async {
                                try {
                                  await locator<ServerProvider>().delete(server);
                                } catch (e) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                                    backgroundColor: Colors.pink,
                                    content: Text(
                                      'Não foi possivel remover este servidor pois ele esta vinculado a uma rotina!',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ));
                                }
                                Navigator.of(context).pop(true);
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
                })
          ],
        )),
      ],
    );
  }
}
