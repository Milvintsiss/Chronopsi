import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'configuration.dart';

void aboutDialog(BuildContext context, Configuration configuration) {
  showAboutDialog(
    context: context,
    applicationName: "Chronopsi",
    applicationVersion: Platform.isWindows || Platform.isLinux ? null : configuration.packageInfo.version,
    applicationIcon: SizedBox(
      height: 50,
      width: 50,
      child: Image.asset('assets/appLogo/logo.png'),
    ),
    children: [
      GestureDetector(
        onTap: () => launch(
          'https://www.buymeacoffee.com/Milvintsiss',
        ),
        child: Text(
          "Un ptiot café?",
          style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic, decoration: TextDecoration.underline),
        ),
      )
    ],
  );
}
