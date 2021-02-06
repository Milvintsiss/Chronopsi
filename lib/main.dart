import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:chronopsi/root_page.dart';
import 'package:chronopsi/theme.dart';

import 'dart:ffi';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/open.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ////init moor
  print("Get SQLite from package");
  open.overrideFor(OperatingSystem.linux, _openOnLinux);
  open.overrideFor(OperatingSystem.windows, _openOnWindows);
  print("Open SQLite in memory");
  final db = sqlite3.openInMemory();
  db.dispose();

  //init locale language
  await initializeDateFormatting();

  //getSavedTheme
  final AdaptiveThemeMode savedThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(MyApp(savedThemeMode));
}

DynamicLibrary _openOnLinux() {
  final script = File(Platform.script.toFilePath());
  print('Script PATH: ${script.path}');
  final libraryNextToScript = File('${script.path}/sqlite3.so');
  print('Library PATH: ${libraryNextToScript.path}');
  return DynamicLibrary.open(libraryNextToScript.path);
}

DynamicLibrary _openOnWindows() {
  final script = File(Platform.script.toFilePath());
  print('Script PATH: ${script.path}');
  final libraryNextToScript = File('${script.parent.path}\\sqlite3.dll');
  print('Library PATH: ${libraryNextToScript.path}');
  return DynamicLibrary.open(libraryNextToScript.path);
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode adaptiveThemeMode;

  MyApp(this.adaptiveThemeMode);

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
              home: RootPage(
                adaptiveThemeMode: _adaptiveThemeMode,
              ),
            ));
  }
}
