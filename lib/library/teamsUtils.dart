import 'dart:io';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const teamsAndroidPackageName = 'com.microsoft.teams';
const teamsIOSUrlScheme = 'msteams://';
const teamsIOSAppStoreLinkScheme =
    'itms-apps://itunes.apple.com/us/app/microsoft-teams/id1113153706';
const teamsWindowsUrlScheme = 'msteams://';
const teamsMacOSUrlScheme = 'msteams://';

Future openTeams(BuildContext context) async {
  if (Platform.isAndroid || Platform.isIOS) {
    await LaunchApp.openApp(
      androidPackageName: teamsAndroidPackageName,
      openStore: true,
      iosUrlScheme: teamsIOSUrlScheme,
      appStoreLink: teamsIOSAppStoreLinkScheme,
    );
  } else if (Platform.isWindows) {
    if (await canLaunch(teamsWindowsUrlScheme)) {
      await launch(teamsWindowsUrlScheme);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Teams n'est pas installé ou n'est pas accessible",
          style: TextStyle(color: Colors.red),
        ),
      ));
    }
  } else if (Platform.isMacOS) {
    if (await canLaunch(teamsMacOSUrlScheme)) {
      await launch(teamsMacOSUrlScheme);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Teams n'est pas installé ou n'est pas accessible",
          style: TextStyle(color: Colors.red),
        ),
      ));
    }
  } else
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "Disponible dans une prochaine MAJ",
        style: TextStyle(color: Colors.red),
      ),
    ));
}
