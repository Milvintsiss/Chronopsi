import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vge/pages/home.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:vge/root_page.dart';
import 'package:vge/theme.dart';

import 'app_state_notifier.dart';

void main() {
  runApp(
    ChangeNotifierProvider<AppStateNotifier>(
      builder: (context) => AppStateNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateNotifier>(builder: (context, appState, child) {
      return MaterialApp(
        title: 'Chronopsi',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: RootPage(),
      );
    });
  }
}
