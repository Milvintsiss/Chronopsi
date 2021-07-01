import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:chronopsi/library/alarm_generation.dart';
import 'package:chronopsi/library/configuration.dart';
import 'package:number_selection/number_selection.dart';
import 'package:vibration/vibration.dart';

import '../root_page.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.configuration}) : super(key: key);

  final Configuration configuration;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isLoading = false;

  bool openClockAppAfterGeneration = true;
  int numberOfDaysToGenerate = 7;
  Duration duration = Duration(hours: 1, minutes: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Theme.of(context).primaryColorDark,
      body: body(),
    );
  }

  Widget body() {
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          children: [
            showOptionWidgetCount("Durée de validité du cache (en jours)",
                widget.configuration.cacheKeepingDuration, (newValue) {
              widget.configuration.sharedPreferences
                  .setInt(cacheKeepingDurationKey, newValue);
              setState(() {
                widget.configuration.cacheKeepingDuration = newValue;
              });
            }),
            showOptionWidget(
              "Coupler les cours ayant le même label se suivant",
              widget.configuration.concatenateSimilarLessons,
              (newValue) {
                widget.configuration.sharedPreferences
                    .setBool(concatenateSimilarLessonsKey, newValue);
                setState(() {
                  widget.configuration.concatenateSimilarLessons = newValue;
                });
              },
              Theme.of(context).primaryColor,
            ),
            showOptionWidget(
              "Design épuré",
              widget.configuration.cleanDisplay,
              (newValue) {
                widget.configuration.sharedPreferences
                    .setBool(cleanDisplayKey, newValue);
                setState(() {
                  widget.configuration.cleanDisplay = newValue;
                });
              },
              Theme.of(context).primaryColor,
            ),
            showDeleteDataButton(),
            Platform.isAndroid ? showGenerateAlarmsButton() : Container(),
          ],
          physics:
              AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        ),
        isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColorLight),
                ),
              )
            : Container()
      ],
    );
  }

  Widget showOptionWidget(
      String label, bool value, void onChanged(newValue), Color firstColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 60),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                  decoration: BoxDecoration(
                    color: firstColor,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Theme.of(context).primaryColor,
              inactiveThumbColor: Theme.of(context).primaryColorLight,
              inactiveTrackColor: Theme.of(context).primaryColor,
            )
          ],
        ),
      ),
    );
  }

  Widget showOptionWidgetCount(
      String label, int value, void onChanged(newValue)) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 60),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: NumberSelection(
                onChanged: onChanged,
                theme: NumberSelectionTheme(
                  draggableCircleColor: Theme.of(context).primaryColorLight,
                  numberColor: Theme.of(context).primaryColor,
                  iconsColor: Theme.of(context).primaryColorLight,
                ),
                direction: Axis.horizontal,
                initialValue: value,
                maxValue: 30,
                minValue: 0,
                withSpring: true,
                onOutOfConstraints: () async {
                  if ((Platform.isAndroid || Platform.isIOS) &&
                      await Vibration.hasVibrator()) Vibration.vibrate();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget showDeleteDataButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).primaryColorLight,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100))),
      ),
      child: Text(
        "Supprimer les données",
        style: TextStyle(fontSize: 18),
      ),
      onPressed: () async {
        AdaptiveThemeMode adaptiveThemeMode = AdaptiveTheme.of(context).mode;
        await widget.configuration.sharedPreferences.clear();
        await widget.configuration.localMoorDatabase.moorDatabase
            .createAllTablesAgain();
        await widget.configuration.localMoorDatabase.moorDatabase
            .close();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RootPage(
                      adaptiveThemeMode: adaptiveThemeMode,
                    ),
            ));
      },
    );
  }

  Widget showGenerateAlarmsButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).primaryColorLight,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100))),
      ),
      child: Text(
        "Générer des alarmes",
        style: TextStyle(fontSize: 18),
      ),
      onPressed: () async {
        AlarmGeneration().showGenerateAlarmsDialog(
            context, widget.configuration,
            isLoadingUpdate: (bool loading) {});
      },
    );
  }
}
