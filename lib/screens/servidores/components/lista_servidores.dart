import 'package:fsbackup/constants.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fsbackup/models/servidor.dart';
import 'package:fsbackup/providers/servidor_provider.dart';
import 'package:fsbackup/screens/servidores/components/edita_servidor.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class ListaServidores extends StatelessWidget {
  ListaServidores({
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
              value: GetIt.instance.get<ServidorProvider>(),
              builder: (context, w) => Consumer<ServidorProvider>(builder: (ctx, data, child) {
                return FutureBuilder<List<Servidor>>(
                    future: data.returnServers(),
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

  DataRow servidorDataRow(Servidor server, BuildContext ctx) {
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
                child: Text(server.name),
              ),
            ],
          ),
        ),
        DataCell(Text(server.hostName)),
        DataCell(Text(server.port?.toString())),
        DataCell(Row(
          children: [
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: ctx,
                    builder: (_) => EditaServidor(server: server),
                  );
                }),
            SizedBox(width: defaultPadding + 5),
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  var sp = GetIt.instance.get<ServidorProvider>();
                  sp.delete(server.id);
                })
          ],
        )),
      ],
    );
  }
}
