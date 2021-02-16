import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:chronopsi/root_page.dart';
import 'package:chronopsi/theme.dart';

import 'dart:ffi';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/open.dart';
import 'package:url_launcher/url_launcher.dart';

import 'library/mailUtils.dart';

const sqlite3_emplacement_windows = 'sqlite3_libraries/windows/sqlite3.dll';
const sqlite3_emplacement_linux = '/sqlite3_libraries/linux/libsqlite3.so';

Future<void> main() async {
  bool isSQLLoaded = true;
  WidgetsFlutterBinding.ensureInitialized();

  print("OS: ${Platform.operatingSystem}");
  print("Version: ${Platform.operatingSystemVersion}");
  print('Script PATH: ${Platform.script.toFilePath()}');

  ////init moor
  print("Get SQLite from package");
  open.overrideFor(OperatingSystem.linux, _openOnLinux);
  open.overrideFor(OperatingSystem.windows, _openOnWindows);
  print("Open SQLite in memory");

  try {
    final db = sqlite3.openInMemory();
    db.dispose();
  } catch (e) {
    print(e);
    isSQLLoaded = false;
  }

  //init locale language
  await initializeDateFormatting();

  //getSavedTheme
  final AdaptiveThemeMode savedThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(MyApp(savedThemeMode, isSQLLoaded));
}

DynamicLibrary _openOnLinux() {
  final library = File(sqlite3_emplacement_linux);
  print('Library PATH: ${library.path}');
  DynamicLibrary dynamicLibrary;
  try {
    dynamicLibrary = DynamicLibrary.open(library.path);
  } catch (e) {
    print(e);
    dynamicLibrary = DynamicLibrary.open('libsqlite3.so');
  }
  return dynamicLibrary;
}

DynamicLibrary _openOnWindows() {
  final library = File(sqlite3_emplacement_windows);
  print('Library PATH: ${library.path}');
  return DynamicLibrary.open(library.path);
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode adaptiveThemeMode;
  final bool isSQLLoaded;

  MyApp(this.adaptiveThemeMode, this.isSQLLoaded);

  @override
  Widget build(BuildContext context) {
    final AdaptiveThemeMode _adaptiveThemeMode =
        adaptiveThemeMode ?? AdaptiveThemeMode.dark;
    return AdaptiveTheme(
        light: AppTheme().lightTheme,
        dark: AppTheme().darkTheme,
        initial: _adaptiveThemeMode,
        builder: (lightTheme, darkTheme) => MaterialApp(
              title: 'Chronopsi',
              theme: lightTheme,
              darkTheme: darkTheme,
              debugShowCheckedModeBanner: false,
              home: isSQLLoaded
                  ? RootPage(
                      adaptiveThemeMode: _adaptiveThemeMode,
                    )
                  : failedLoadingSQLite(),
            ));
  }

  Widget failedLoadingSQLite() {
    return Scaffold(
        body: RichText(
            text: TextSpan(children: [
      TextSpan(
          text: "Le chargement de la librarie SQLite a échoué, "
              "si vous executez Chronopsi depuis un Linux "
              "tentez d'installer la librairie avec la commande "
              "\"apt install libsqlite3-dev\" "
              "et redémarrez l'application. "
              "Si cela ne fonctionne toujours pas "
              "veuillez me contacter a l'adresse ",
          style: TextStyle(color: Colors.red)),
      ClickableTextSpan(
        text: "milvintsiss@gmail.com",
        onTap: () {
          MailLauncher mailLauncher = MailLauncher(
              emailAddress: contactMail,
              subject: "Chronopsi",
              body: "OS: ${Platform.operatingSystem}\n"
                  "Version: ${Platform.operatingSystemVersion}");
          print(mailLauncher);
          launch(mailLauncher.toString());
        },
      )
    ])));
  }
}
