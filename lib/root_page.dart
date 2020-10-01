import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vge/pages/connection.dart';

import 'app_state_notifier.dart';
import 'pages/home.dart';

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

  SharedPreferences sharedPreferences;

  String logIn;


  @override
  void initState() {
    super.initState();
    initAndGetSharedPreferences();
  }

  void initAndGetSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();

    bool isDarkTheme = sharedPreferences.getBool('theme') ?? true;
    Provider.of<AppStateNotifier>(context)
        .updateTheme(isDarkTheme);
    sharedPreferences.setBool('theme', isDarkTheme);
    if(sharedPreferences.getString('logIn') == null || sharedPreferences.getString('logIn') == ""){
      setState(() {
        appState = AppState.disconnected;
      });
    }else {
      logIn = sharedPreferences.getString('logIn');
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
        return Home(logIn: logIn,);
      }
      break;
      case AppState.disconnected: {
        return Connection();
      }
      break;
    }
  }
}