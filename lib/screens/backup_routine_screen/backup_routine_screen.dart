import 'package:flutter/material.dart';
import 'package:fsbackup/constants.dart';
import 'package:fsbackup/screens/backup_routine_screen/components/edit_backup_routine.dart';
import 'package:fsbackup/screens/backup_routine_screen/components/list_backup_routine.dart';

import 'package:fsbackup/shared/components/header.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart'; //Add this line to multi-language-support

class BackupRoutineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(
              title: AppLocalizations.of(context).backupRoutinesPageTitle,
              actions: [
                ElevatedButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: defaultPadding * 1.5, vertical: defaultPadding),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => EditBackupRoutine(),
                    );
                  },
                  icon: Icon(Icons.add),
                  label: Text("Add"),
                ),
              ],
            ),
            SizedBox(height: defaultPadding),
            Expanded(
              child: ListBackupRoutine(),
            ),
          ],
        ),
      ),
    );
  }
}
