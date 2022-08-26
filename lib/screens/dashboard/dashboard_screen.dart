import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/constants.dart';
import 'package:fsbackup/providers/fila_provider.dart';
import 'package:flutter/material.dart';
import 'package:fsbackup/providers/log_provider.dart';
import 'package:fsbackup/screens/dashboard/components/fila_backups.dart';
import 'package:fsbackup/screens/dashboard/components/log_view.dart';
import 'package:fsbackup/shared/components/header.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart'; //Add this line to multi-language-support

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  ScrollController singleChildScrollController = ScrollController();
  ScrollController logScrollController = ScrollController();
  Size screenSize;
  bool _showLog = true;
  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              height: _showLog ? ((screenSize.height * .7) - 40) : screenSize.height - 30,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Header(
                    title: AppLocalizations.of(context).dashboardPageTitle,
                    actions: [
                      //_showLog
                      ElevatedButton.icon(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: defaultPadding * 1.5, vertical: defaultPadding),
                        ),
                        onPressed: () => locator<LogProvider>().clear(),
                        icon: Icon(Icons.delete),
                        label: Text('Clear Log'),
                      ),
                      ElevatedButton.icon(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: defaultPadding * 1.5, vertical: defaultPadding),
                        ),
                        onPressed: () {
                          setState(() {
                            _showLog = !_showLog;
                          });
                        },
                        icon: Icon(_showLog ? Icons.visibility : Icons.visibility_off),
                        label: Text(AppLocalizations.of(context).btnShowLog),
                      ),
                      ElevatedButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: defaultPadding * 1.5, vertical: defaultPadding),
                        ),
                        onPressed: () {
                          locator<FilaProvider>().start();
                        },
                        icon: Icon(Icons.play_arrow),
                        label: Text(AppLocalizations.of(context).btnStart),
                      ),
                      ElevatedButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(horizontal: defaultPadding * 1.5, vertical: defaultPadding),
                        ),
                        onPressed: () {
                          locator<FilaProvider>().stop();
                        },
                        icon: Icon(Icons.stop),
                        label: Text('Stop'),
                      ),
                    ],
                  ),
                  SizedBox(height: defaultPadding),
                  Text(
                    'Fila de backups em andamento:',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Expanded(
                    child: FilaBackupWidget(),
                  ),
                ],
              ),
            ),

            //logs
            if (_showLog)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: screenSize.height * .3,
                child: Container(
                  padding: EdgeInsets.all(0),
                  child: LogViewWidget(scrollController: logScrollController),
                ),
              )
          ],
        ),
      ),
    );
  }
}
