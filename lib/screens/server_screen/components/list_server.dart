import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/constants.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fsbackup/models/server_model.dart';
import 'package:fsbackup/providers/server_provider.dart';
import 'package:fsbackup/screens/server_screen/components/edit_server.dart';

import 'package:provider/provider.dart';

class ListServer extends StatelessWidget {
  ListServer({
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
              value: locator<ServerProvider>(),
              builder: (context, w) => Consumer<ServerProvider>(builder: (ctx, data, child) {
                return FutureBuilder<List<ServerModel>>(
                    future: data.getAll(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.length == 0) {
                          return Center(child: Text("Não ha servidores cadastrados"));
                        } else if (snapshot.data.length > 0) {
                          return DataTable2(
                              columnSpacing: defaultPadding,
                              minWidth: 600,
                              columns: [
                                DataColumn(label: Text("Nome")),
                                DataColumn(label: Text("Host")),
                                DataColumn(label: Text("Porta")),
                                DataColumn(label: Text("Ações")),
                              ],
                              rows: snapshot.data.map<DataRow>((server) => servidorDataRow(server, ctx)).toList());
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

  DataRow servidorDataRow(ServerModel server, BuildContext ctx) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              SvgPicture.asset(
                server.icon,
                height: 30,
                width: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(server.name == null ? '' : server.name),
              ),
            ],
          ),
        ),
        DataCell(Text('${server.host}')),
        DataCell(Text(server.port?.toString())),
        DataCell(Row(
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
                        title: Text("Confirmar"),
                        content: Text("Tem certeza que deseja deletar este item?"),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop(true);
                                await locator<ServerProvider>().delete(server.id);
                              },
                              child: Text("DELETE")),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text("CANCEL"),
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
