import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vge/library/configuration.dart';
import 'package:vge/local_moor_database.dart';
import 'package:vge/pages/connection_page.dart';

import 'app_state_notifier.dart';
import 'local_database.dart';
import 'pages/home_page.dart';

enum AppState { loading, connected, disconnected }

class RootPage extends StatefulWidget {
  RootPage({Key key}) : super(key: key);

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
        Platform.isWindows ? null : await PackageInfo.fromPlatform();

    //init sharedPreferences
    configuration.sharedPreferences = await SharedPreferences.getInstance();
    if (!configuration.sharedPreferences.containsKey('countKey')) {
      await configuration.sharedPreferences.setInt('countKey', 0);
    }
    configuration.concatenateSimilarLessons =
        configuration.sharedPreferences.getBool('concatenateSimilarLessons') ??
            CONCATENATE_SIMILAR_LESSONS_DEFAULT_VALUE;
    configuration.cleanDisplay =
        configuration.sharedPreferences.getBool('cleanDisplay') ??
            CLEAN_DISPLAY_DEFAULT_VALUE;
    configuration.cacheKeepingDuration =
        configuration.sharedPreferences.getInt('cacheKeepingDuration') ??
            CACHE_KEEPING_DURATION_DEFAULT_VALUE;

    bool isDarkTheme = configuration.sharedPreferences.getBool('theme') ??
        IS_DARK_THEME_DEFAULT_VALUE;
    Provider.of<AppStateNotifier>(context).updateTheme(isDarkTheme);
    configuration.sharedPreferences.setBool('theme', isDarkTheme);

    if (configuration.sharedPreferences.getString('logIn') == null ||
        configuration.sharedPreferences.getString('logIn') == "") {
      setState(() {
        appState = AppState.disconnected;
      });
    } else {
      configuration.logIn = configuration.sharedPreferences.getString('logIn');
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
