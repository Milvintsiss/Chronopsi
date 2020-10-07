import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void aboutDialog (BuildContext context){
  showAboutDialog(
    context: context,
    applicationIcon: SizedBox(
        height: 50,
        width: 50,
        child: Icon(Icons.circle)),
    children: [
      GestureDetector(
        onTap: () => launch('https://www.google.com',),
        child: Text("help me", style: TextStyle(color: Colors.blue),),
      )
    ],
  );
}