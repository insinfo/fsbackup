import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/providers/fila_provider.dart';
import 'package:fsbackup/responsive.dart';

import 'package:flutter/material.dart';

import '../../constants.dart';

import '../../shared/components/header.dart';

import 'components/fila_backups.dart';
import 'components/storage_details.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(
              title: 'Dashboard',
              actions: [
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
                      if (Responsive.isMobile(context)) SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) StarageDetails(),
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
    );
  }
}
