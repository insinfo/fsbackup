import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/providers/fila_provider.dart';

import 'package:flutter/material.dart';
import 'package:fsbackup/screens/dashboard/components/log_view.dart';

import '../../constants.dart';

import '../../shared/components/header.dart';

import 'components/fila_backups.dart';

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
  Size size;
  bool _showLog = true;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            height: size.height * .7,
            right: 0,
            child: Container(
              child: SingleChildScrollView(
                controller: singleChildScrollController,
                padding: EdgeInsets.all(defaultPadding),
                child: Column(
                  children: [
                    Header(
                      title: 'Dashboard',
                      actions: [
                        //_showLog
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
                          label: Text('Show Log'),
                        ),
                        ElevatedButton.icon(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: defaultPadding * 1.5, vertical: defaultPadding),
                          ),
                          onPressed: () {
                            locator<FilaProvider>().start();
                          },
                          icon: Icon(Icons.sync),
                          label: Text('Iniciar'),
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
                              FilaBackupWidget(),
                              //if (Responsive.isMobile(context)) SizedBox(height: defaultPadding),
                              // if (Responsive.isMobile(context)) StarageDetails(),
                            ],
                          ),
                        ),
                        /*if (!Responsive.isMobile(context)) SizedBox(width: defaultPadding),
                        // On Mobile means if the screen is less than 850 we dont want to show it
                        if (!Responsive.isMobile(context))
                          Expanded(
                            flex: 2,
                            child: StarageDetails(),
                          ),*/
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          //logs
          if (_showLog)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: size.height * .3,
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: LogViewWidget(scrollController: logScrollController),
              ),
            )
        ],
      ),
    );
  }
}
