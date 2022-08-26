import 'package:flutter/material.dart';
import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/constants.dart';
import 'package:fsbackup/providers/backup_routine_provider.dart';

import 'package:fsbackup_shared/fsbackup_shared.dart';

class RoutineLogViewDialog extends StatefulWidget {
  final BackupRoutineModel routine;

  const RoutineLogViewDialog(this.routine, {Key key}) : super(key: key);

  @override
  RoutineLogViewDialogState createState() => RoutineLogViewDialogState();
}

class RoutineLogViewDialogState extends State<RoutineLogViewDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        centerTitle: false,
        title: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text('Log: ${widget.routine.name}'),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  decoration: InputDecoration(hintText: 'Search'),
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Alert'),
                        content: Text('Are you sure you want to clear the log?'),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop(true);
                                /*await Navigator.of(context)
                                    .push(new MaterialPageRoute(builder: (context) => BackupRoutineScreen()));
                                setState(() {});*/
                                await locator<BackupRoutineProvider>().cleanLog(widget.routine);
                              },
                              child: Text('Confirm')),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                        ],
                      );
                    });
              },
              child: Text('Clean', style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white))),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SelectableText.rich(
          TextSpan(text: widget.routine.log),
        ),
      ),
    );
  }
}
