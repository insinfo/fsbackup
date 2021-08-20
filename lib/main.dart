import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fsbackup/pages/process/process_page.dart';
import 'package:fsbackup/pages/help/help_page.dart';
import 'package:fsbackup/pages/home/home_page.dart';
import 'package:fsbackup/pages/server/server_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final primaryColor = Colors.red;
  final accentColor = Colors.blue;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FSBackup',
      theme: ThemeData(primaryColor: primaryColor, accentColor: accentColor),
      darkTheme: ThemeData(primaryColor: primaryColor, accentColor: accentColor, brightness: Brightness.dark),
      routes: {
        '/': (context) => HomePage(),
        '/server': (context) => ServerPage(),
        '/process': (context) => ProcessPage(),
        '/help': (context) => HelpPage(),
      },
    );
  }
}
