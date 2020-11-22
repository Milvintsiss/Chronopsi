import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vge/library/alarm_generation.dart';
import 'package:vge/library/configuration.dart';
import 'package:vge/library/custom_number_selection.dart';

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
                  .setInt('cacheKeepingDuration', newValue);
              setState(() {
                widget.configuration.cacheKeepingDuration = newValue;
              });
            }),
            showOptionWidget(
              "Coupler les cours ayant le même label qui se suivent",
              widget.configuration.concatenateSimilarLessons,
              (newValue) {
                widget.configuration.sharedPreferences
                    .setBool('concatenateSimilarLessons', newValue);
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
                    .setBool('cleanDesign', newValue);
                setState(() {
                  widget.configuration.cleanDisplay = newValue;
                });
              },
              Theme.of(context).primaryColor,
            ),
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
              child: CustomNumberSelection(
                onChanged: onChanged,
                firstColor: Theme.of(context).primaryColorLight,
                textColor: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).primaryColorDark.withOpacity(0.7),
                direction: Axis.horizontal,
                initialValue: value,
                maxValue: 30,
                minValue: 0,
                withSpring: true,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget showGenerateAlarmsButton() {
    return RaisedButton(
      color: Theme.of(context).primaryColorLight,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(100))),
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
