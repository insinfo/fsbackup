import 'package:flutter/material.dart';
import 'package:fsbackup/constants.dart';
import 'package:fsbackup/screens/server_screen/components/edit_server.dart';
import 'package:fsbackup/screens/server_screen/components/list_server.dart';

import 'package:fsbackup/shared/components/header.dart';

class ServerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Header(
              title: 'Servidores',
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
                      builder: (_) => EditServer(),
                    );
                  },
                  icon: Icon(Icons.add),
                  label: Text("Add"),
                ),
              ],
            ),
            SizedBox(height: defaultPadding),
            Expanded(
              child: ListServer(),
            ),
          ],
        ),
      ),
    );
  }
}
