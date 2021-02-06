import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chronopsi/library/configuration.dart';
import 'package:chronopsi/local_moor_database.dart';
import 'package:chronopsi/pages/connection_page.dart';

import 'pages/home_page.dart';

enum AppState {loading, connected, disconnected }

class RootPage extends StatefulWidget {
  RootPage({Key key, @required this.adaptiveThemeMode}) : super(key: key);

  final AdaptiveThemeMode adaptiveThemeMode;
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AppState appState = AppState.loading;

  Configuration configuration = Configuration();

  @override
  void initState() {
    super.initState();
    initAndGetSharedPreferences();
  }

  void initAndGetSharedPreferences() async {
    // //init SQLite Database
    // configuration.localDatabase = LocalDatabase();
    // await configuration.localDatabase.init();

    //init Moor Database
    configuration.localMoorDatabase = LocalMoorDatabase();
    //get packageInfo
    configuration.packageInfo =
        Platform.isWindows || Platform.isLinux ? null : await PackageInfo.fromPlatform();

    //init sharedPreferences
    configuration.sharedPreferences = await SharedPreferences.getInstance();

    configuration.concatenateSimilarLessons =
        configuration.sharedPreferences.getBool(concatenateSimilarLessonsKey) ??
            CONCATENATE_SIMILAR_LESSONS_DEFAULT_VALUE;
    configuration.cleanDisplay =
        configuration.sharedPreferences.getBool(cleanDisplayKey) ??
            CLEAN_DISPLAY_DEFAULT_VALUE;
    configuration.cacheKeepingDuration =
        configuration.sharedPreferences.getInt(cacheKeepingDurationKey) ??
            CACHE_KEEPING_DURATION_DEFAULT_VALUE;

    configuration.isDarkTheme = widget.adaptiveThemeMode.isDark;

    if (configuration.sharedPreferences.getString(logInKey) == null ||
        configuration.sharedPreferences.getString(logInKey) == "") {
      setState(() {
        appState = AppState.disconnected;
      });
    } else {
      configuration.logIn = configuration.sharedPreferences.getString(logInKey);
      configuration.password =
          configuration.sharedPreferences.getString(passwordKey);
      setState(() {
        appState = AppState.connected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (appState) {
      case AppState.loading:
        {
          return Scaffold(
            backgroundColor: Color(0xFF2a3035),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/appLogo/logo_avec_padding.png'),
                CircularProgressIndicator(),
              ],
            ),
          );
        }
        break;
      case AppState.connected:
        {
          return HomePage(configuration: configuration);
        }
        break;
      case AppState.disconnected:
        {
          return LogInPage(
            configuration: configuration,
          );
        }
        break;
      default:
        {
          return Container();
        }
        break;
    }
  }
}
