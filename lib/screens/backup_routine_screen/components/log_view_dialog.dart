import 'package:flutter/material.dart';
import 'package:fsbackup/constants.dart';
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
        title: Text('Log of ${widget.routine.name}'),
        actions: [
          /* new TextButton(
              onPressed: () {
                
              },
              child: Text('SAVE',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.white))),*/
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SelectableText(widget.routine.log),
      ),
    );
  }
}
