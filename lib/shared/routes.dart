import 'package:flutter/material.dart';
import 'package:fsbackup/screens/backup_routine_screen/backup_routine_screen.dart';
import 'package:fsbackup/screens/dashboard/dashboard_screen.dart';

import 'package:fsbackup/screens/server_screen/server_screen.dart';

import 'package:page_transition/page_transition.dart';

final Map<String, Widget> pageRoutes = {
  '/': DashboardScreen(),
  '/dashboard': DashboardScreen(),
  '/servidores': ServerScreen(),
  '/rotinas': BackupRoutineScreen(),
};

var currentRoute = '/dashboard';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  final pageName = settings.name;

  Widget page;
  pageRoutes.forEach((key, value) {
    if (key == pageName) {
      page = value;
    }
  });

  currentRoute = pageName;
  return PageTransition(type: PageTransitionType.bottomToTop, child: page);
  //return MaterialPageRoute(settings: settings, builder: (context) => page);
}
