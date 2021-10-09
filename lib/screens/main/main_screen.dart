import 'package:flutter/material.dart';
import 'package:fsbackup/app_injector.dart';

import 'package:fsbackup/providers/menu_provider.dart';
import 'package:fsbackup/responsive.dart';
import 'package:fsbackup/screens/main/components/side_menu.dart';

import 'package:fsbackup/shared/routes.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final navigatorKey = GlobalObjectKey<NavigatorState>(context);
    var mp = locator.get<MenuProvider>();

    return Scaffold(
      key: mp.scaffoldKey,
      drawer: SideMenu(navigatorKey: navigatorKey),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(navigatorKey: navigatorKey),
              ),
            Expanded(
                // It takes 5/6 part of the screen
                flex: 5,
                child: Navigator(
                  key: navigatorKey, initialRoute: '/',
                  onGenerateRoute: onGenerateRoute,
                  // DashboardScreen(),
                )),
          ],
        ),
      ),
    );
  }
}
