import 'package:flutter/material.dart';
import 'package:fsbackup/constants.dart';
import 'package:fsbackup/providers/servidor_provider.dart';
import 'package:fsbackup/screens/servidores/components/edita_servidor.dart';

import 'package:fsbackup/shared/components/header.dart';

import 'package:fsbackup/screens/servidores/components/lista_servidores.dart';
import 'package:provider/provider.dart';

class ServidoresScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var servidorProvider = Provider.of<ServidorProvider>(context, listen: false);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(
              title: 'Gerencia Servidores',
              actions: [
                ElevatedButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: defaultPadding * 1.5,
                      vertical: defaultPadding,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ChangeNotifierProvider<ServidorProvider>.value(
                        value: servidorProvider,
                        child: EditaServidor(),
                      ),
                    );
                  },
                  icon: Icon(Icons.add),
                  label: Text("Add"),
                ),
              ],
            ),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      //MyFiles(),
                      SizedBox(height: defaultPadding),
                      ListaServidores(),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
