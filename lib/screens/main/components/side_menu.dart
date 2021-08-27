import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fsbackup/shared/routes.dart';

class SideMenu extends StatelessWidget {
  final GlobalObjectKey<NavigatorState> navigatorKey;
  SideMenu({
    Key key,
    this.navigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo-backup-2.png"),
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashbord.svg",
            press: () {
              if (currentRoute != '/dashboard') {
                navigatorKey.currentState.pushReplacementNamed('/dashboard');
              }
            },
          ),
          DrawerListTile(
            title: "Servidores",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              if (currentRoute != '/servidores') {
                navigatorKey.currentState.pushReplacementNamed('/servidores');
              }
              // Navigator.of(context).pushNamed('/servidores');
            },
          ),
          DrawerListTile(
            title: 'Rotinas',
            svgSrc: 'assets/icons/menu_task.svg',
            press: () {
              if (currentRoute != '/rotinas') {
                navigatorKey.currentState.pushReplacementNamed('/rotinas');
              }
            },
          ),
          /*DrawerListTile(
            title: "Documents",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Store",
            svgSrc: "assets/icons/menu_store.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Notification",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Profile",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Settings",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () {},
          ),*/
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key key,
    // For selecting those three line once press "Command+D"
    this.title,
    this.svgSrc,
    this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        color: Colors.white54,
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
