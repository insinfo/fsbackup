import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/constants.dart';

import 'package:fsbackup/screens/main/main_screen.dart';
import 'package:fsbackup/shared/utils/process_helper.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:os/file_system.dart';

var pipe = NamedPipeWindows('fsbackup2');
void main() {
  //var hd = CreateMutex();
  var countRunning = ProcessHelper.countProcessInstance('fsbackup.exe');
  if (countRunning > 1) {
    notifyOpenInstance();
    exit(1);
  }
  //startPipeServer();
  notifyOpenInstance();
  runApp(MyApp());
}

void notifyOpenInstance() {
  var w = pipe.openWrite();
  w.connect();
  w.addString('Isaque');
  w.close();
  print('notifyInstace');
}

void startPipeServer() {}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate, // Add this line
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''), // English, no country code
          const Locale('es', ''), // Spanish, no country code
          const Locale('pt', ''),
          // ... other locales the app supports
        ],
        debugShowCheckedModeBanner: false,
        title: 'FSBackup',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: bgColor,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.white),
          canvasColor: secondaryColor,
        ),
        home: FutureBuilder(
          //inicializa o injetor de dependencias
          future: appInjector(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return MainScreen();
            }
            return Scaffold(backgroundColor: bgColor, body: Center(child: CircularProgressIndicator()));
          },
        ));
  }
}
