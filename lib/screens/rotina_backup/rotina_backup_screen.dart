import 'package:flutter/material.dart';
import 'package:fsbackup/constants.dart';
import 'package:fsbackup/screens/rotina_backup/components/edita_rotina_backup.dart';
import 'package:fsbackup/screens/rotina_backup/components/lista_rotina_backup.dart';

import 'package:fsbackup/shared/components/header.dart';

class RotinaBackupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(
              title: 'Rotinas',
              actions: [
                ElevatedButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: defaultPadding * 1.5, vertical: defaultPadding),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => EditaRotinaBackup(),
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
                      SizedBox(height: defaultPadding),
                      ListaRotinaBackup(),
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
