import 'package:flutter/material.dart';
import 'package:fsbackup/constants.dart';

import 'package:fsbackup/providers/menu_provider.dart';
import 'package:fsbackup/providers/servidor_provider.dart';
import 'package:fsbackup/screens/main/main_screen.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FSBackup',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      home: MultiProvider(
          providers: [
            ChangeNotifierProvider<ServidorProvider>(
              create: (context) => ServidorProvider(),
            ),
            ChangeNotifierProvider<MenuProvider>(
              create: (context) => MenuProvider(),
            ),
          ],
          builder: (context, child) {
            return MainScreen();
          }),
    );
  }
}
