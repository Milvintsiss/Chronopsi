import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vge/root_page.dart';
import 'package:vge/theme.dart';

import 'app_state_notifier.dart';

import 'dart:ffi';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/open.dart';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

Future<void> main() async {
  bool isSQLLoaded = true;
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

  runApp(
    ChangeNotifierProvider<AppStateNotifier>(
      builder: (context) => AppStateNotifier(),
      child: MyApp(isSQLLoaded),
    ),
  );
}

DynamicLibrary _openOnLinux() {
  final script = File(Platform.script.toFilePath());
  final libraryNextToScript = kDebugMode
      ? File('${script.parent.path}/libsqlite3.so')
      : File('${script.parent.path}/lib/libsqlite3.so');
  DynamicLibrary dynamicLibrary;
  try {
    dynamicLibrary = DynamicLibrary.open(libraryNextToScript.path);
  } catch (e) {
    print(e);
    dynamicLibrary = DynamicLibrary.open('libsqlite3.so');
  }
  return dynamicLibrary;
}

DynamicLibrary _openOnWindows() {
  final script = File(Platform.script.toFilePath());
  print('Script PATH: ${script.path}');
  final libraryNextToScript = File('${script.parent.path}\\lsqlite3.dll');
  print('Library PATH: ${libraryNextToScript.path}');
  return DynamicLibrary.open(libraryNextToScript.path);
}

class MyApp extends StatelessWidget {
  MyApp(this.isSQLLoaded);

  bool isSQLLoaded;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateNotifier>(builder: (context, appState, child) {
      return MaterialApp(
          title: 'Chronopsi',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: isSQLLoaded ? RootPage() : failedLoadingSQLite());
    });
  }

  Widget failedLoadingSQLite() {
    return Scaffold(
      body: Text("Le chargement de la librarie SQLite a échoué, "
          "si vous executez Chronopsi depuis un Linux "
          "tentez d'installer la librairie avec la commande "
          "\"apt install libsqlite3-dev\" "
          "et redémarrez l'application. "
          "Si cela ne fonctionne toujours pas "
          "veuillez me contacter a l'adresse milvintsiss@gmail.com ."),
    );
  }
}
