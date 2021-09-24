import 'package:flutter/material.dart';
import 'package:fsbackup/constants.dart';
import 'package:fsbackup/screens/backup_routine_screen/components/edit_backup_routine.dart';
import 'package:fsbackup/screens/backup_routine_screen/components/list_backup_routine.dart';

import 'package:fsbackup/shared/components/header.dart';

class BackupRoutineScreen extends StatelessWidget {
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
                      builder: (_) => EditBackupRoutine(),
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
                      ListBackupRoutine(),
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
