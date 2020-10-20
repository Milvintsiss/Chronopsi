import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:number_selection/number_selection.dart';
import 'package:vge/library/configuration.dart';

import '../database.dart';
import '../day.dart';

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
            showGenerateAlarmsButton(),
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
        showGenerateAlarmsDialog();
      },
    );
  }

  void showGenerateAlarmsDialog() {
    Dialog dialog = Dialog(
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30))),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Générer des alarmes",
                  style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                Divider(
                  thickness: 2,
                  height: 35,
                  color: Theme.of(context).primaryColorLight,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorDark,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Générer pour",
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 40,
                        child: NumberSelection(
                          firstColor: Theme.of(context).primaryColorLight,
                          textColor: Theme.of(context).primaryColor,
                          direction: Axis.horizontal,
                          initialValue: numberOfDaysToGenerate,
                          maxValue: 7,
                          minValue: 1,
                          withSpring: true,
                          onChanged: (newValue) =>
                              numberOfDaysToGenerate = newValue,
                        ),
                      ),
                      Text(
                        "jours",
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 20,
                      child: Text("Programmer l'alarme",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    Transform.scale(
                      scale: 0.6,
                      child: DurationPicker(
                          circleColor: Theme.of(context).primaryColorLight,
                          duration: duration,
                          onChange: (newValue) {
                            setState(() {
                              duration = newValue;
                            });
                          }),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 20,
                      child: Text("avant le début du cours",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                showOptionWidget(
                  "Ouvrir l'appli Horloge après génération",
                  openClockAppAfterGeneration,
                  (newValue) {
                    setState(() {
                      openClockAppAfterGeneration = newValue;
                    });
                  },
                  Theme.of(context).primaryColorDark,
                ),
                RaisedButton(
                  color: Theme.of(context).primaryColorDark,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      side: BorderSide(
                        color: Theme.of(context).primaryColorLight,
                        width: 2,
                      )),
                  child: Text("Générer",
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(context);
                    generateAlarms();
                  },
                )
              ],
            ),
          );
        },
      ),
    );
    showDialog(context: context, child: dialog);
  }

  void generateAlarms() async {
    setState(() {
      isLoading = true;
    });

    double preparationAndTransportTime = duration.inMinutes / 60;

    for (int i = 0; i < numberOfDaysToGenerate; i++) {
      Day day = await Database().getDay(
          widget.configuration.logIn,
          Database().convertDateTimeToMMJJAAAAString(
              DateTime.now().add(Duration(days: i + 1))));
      day.init(false);

      if (day.lessons.length > 0) {
        double alarmTime = day.lessons[0].start - preparationAndTransportTime;
        int hour = alarmTime.round();
        int minutes =
            (double.parse(".${alarmTime.toString().split('.')[1]}") * 60)
                .round();

        final AndroidIntent intent = AndroidIntent(
          action: 'android.intent.action.SET_ALARM',
          arguments: <String, dynamic>{
            'android.intent.extra.alarm.DAYS': <int>[
              DateTime.now().add(Duration(days: i + 2)).weekday
            ],
            'android.intent.extra.alarm.HOUR': hour,
            'android.intent.extra.alarm.MINUTES': minutes,
            'android.intent.extra.alarm.SKIP_UI': !openClockAppAfterGeneration,
            'android.intent.extra.alarm.MESSAGE':
                "Cours en salle ${day.lessons[0].room} (${day.lessons[0].subject})",
          },
        );
        intent.launch();
      }
    }
    setState(() {
      isLoading = false;
    });
  }
}
