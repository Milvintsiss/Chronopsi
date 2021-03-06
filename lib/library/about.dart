import 'dart:io';

import 'package:chronopsi/library/mailUtils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'configuration.dart';

const linkBuyMeACoffee = 'https://www.buymeacoffee.com/Milvintsiss';
const linkGithub = 'https://github.com/Milvintsiss/Chronopsi';
const linkPlayStore =
    'https://play.google.com/store/apps/details?id=com.milvintsiss.chronopsi';
const linkAppStore = 'https://apps.apple.com/fr/app/chronopsi/id1540249743';

void aboutDialog(BuildContext context, Configuration configuration) {
  showDialog(
    context: context,
    builder: (context) => Theme(
      data: ThemeData(
          dialogBackgroundColor: Theme.of(context).primaryColor,
          textTheme: TextTheme(
              headline5: TextStyle(color: Theme.of(context).primaryColorLight),
              bodyText2: TextStyle(
                  color:
                      Theme.of(context).primaryColorLight.withOpacity(0.8)))),
      child: AboutDialog(
        applicationName: "Chronopsi",
        applicationVersion: Platform.isWindows || Platform.isLinux
            ? null
            : configuration.packageInfo.version,
        applicationIcon: SizedBox(
          height: 70,
          width: 70,
          child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColorDark.withOpacity(0.5),
              ),
              padding: EdgeInsets.all(10),
              child: Image.asset('assets/appLogo/logo.png')),
        ),
        children: [
          RichText(
            text: TextSpan(
              children: [
                ClickableTextSpan(
                  text: "Un ptiot café?",
                  onTap: () => launch(linkBuyMeACoffee),
                ),
                TextSpan(
                    text: "\n\nUn bug? Une suggestion? -> ",
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
                ClickableTextSpan(
                  text: contactMail,
                  onTap: () {
                    MailLauncher mailLauncher = MailLauncher(
                        emailAddress: contactMail,
                        subject: "Chronopsi",
                        body: "OS: ${Platform.operatingSystem}\n"
                            "Version: ${Platform.operatingSystemVersion}");
                    print(mailLauncher);
                    launch(mailLauncher.toString());
                  },
                ),
                TextSpan(
                  text:
                      "\n\nVous avez envie de participer à l'amélioration de Chronopsi? -> ",
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                ),
                ClickableTextSpan(
                  text: linkGithub,
                  onTap: () => launch(linkGithub),
                ),
                TextSpan(
                  text:
                      "\n\nChronopsi est un projet étudiant à but non lucratif, "
                      "cependant vous pouvez rémunerer son créateur en participant "
                      "à l'amélioration de son portfolio par l'ajout d'une note "
                      "sur ${Platform.isIOS ? "l'" : "le "}",
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                ),
                if (Platform.isAndroid || Platform.isIOS)
                  ClickableTextSpan(
                      text: Platform.isAndroid ? "PlayStore" : "AppStore",
                      onTap: () => launch(
                          Platform.isAndroid ? linkPlayStore : linkAppStore))
                else
                  TextSpan(
                    text: "PlayStore/AppStore",
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight),
                  ),
                TextSpan(text: ' ❤'),
              ],
            ),
          )
        ],
      ),
    ),
  );
}


