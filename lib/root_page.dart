import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vge/library/configuration.dart';
import 'package:vge/pages/connection_page.dart';

import 'app_state_notifier.dart';
import 'pages/home_page.dart';

enum AppState{
  loading,
  connected,
  disconnected
}

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
    configuration.sharedPreferences = await SharedPreferences.getInstance();
    configuration.packageInfo = await PackageInfo.fromPlatform();
    if (!configuration.sharedPreferences.containsKey('countKey')) {
      await configuration.sharedPreferences.setInt('countKey', 0);
    }
    configuration.concatenateSimilarLessons = configuration.sharedPreferences.getBool('concatenateSimilarLessons') ?? true;
    configuration.cleanDisplay = configuration.sharedPreferences.getBool('cleanDisplay') ?? true;

    bool isDarkTheme = configuration.sharedPreferences.getBool('theme') ?? true;
    Provider.of<AppStateNotifier>(context)
        .updateTheme(isDarkTheme);
    configuration.sharedPreferences.setBool('theme', isDarkTheme);
    if(configuration.sharedPreferences.getString('logIn') == null || configuration.sharedPreferences.getString('logIn') == ""){
      setState(() {
        appState = AppState.disconnected;
      });
    }else {
      configuration.logIn = configuration.sharedPreferences.getString('logIn');
      setState(() {
        appState = AppState.connected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    switch (appState){
      case AppState.loading: {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      break;
      case AppState.connected: {
        return HomePage(configuration: configuration);
      }
      break;
      case AppState.disconnected: {
        return LogInPage(configuration: configuration,);
      }
      break;
    }
  }
}