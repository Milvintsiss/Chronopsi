import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';

import '../database.dart';
import '../day.dart';
import 'configuration.dart';
import 'custom_duration_picker.dart';
import 'custom_number_selection.dart';

class AlarmGeneration {
  bool openClockAppAfterGeneration = true;
  int numberOfDaysToGenerate = 7;
  Duration duration = Duration(hours: 1, minutes: 0);
  bool isLoading = false;
  double loadingValue = 0;

  void showGenerateAlarmsDialog(
      BuildContext context, Configuration configuration,
      {Function isLoadingUpdate, int weekDay, Day day, Lesson lesson}) {
    bool isSingleAlarm = weekDay != null && day != null && lesson != null;
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
                  isSingleAlarm ? "Générer une alarme" : "Générer des alarmes",
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
                isSingleAlarm
                    ? Container()
                    : Container(
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
                              child: CustomNumberSelection(
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
                      child: CustomDurationPicker(
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
                  context,
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
                    if (isSingleAlarm) {
                      Navigator.pop(context);
                      generateSingleAlarm(
                          configuration, isLoadingUpdate, weekDay, day, lesson);
                    } else {
                      generateAlarms(
                          configuration, isLoadingUpdate, setState, context);
                    }
                  },
                ),
                isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(
                          value: loadingValue,
                          backgroundColor: Theme.of(context).primaryColorDark,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColorLight),
                        ),
                      )
                    : Container(),
              ],
            ),
          );
        },
      ),
    );
    showDialog(context: context, builder: (context) => dialog);
  }

  void generateAlarms(Configuration configuration, Function isLoadingUpdate,
      StateSetter setState, BuildContext context) async {
    setState(() => isLoading = true);
    //isLoadingUpdate(true);

    double preparationAndTransportTime = duration.inMinutes / 60;

    List<Day> days = [];

    for (int i = 0; i < numberOfDaysToGenerate; i++) {
      setState(() => loadingValue = i / numberOfDaysToGenerate);
      Day day = await Database().getDay(
          configuration: configuration,
          dateTime: DateTime.now().add(Duration(days: i + 1)));
      day.init(false);
      days.add(day);
    }

    days.forEach((day) {
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
              DateTime.now().add(Duration(days: days.indexOf(day) + 2)).weekday
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
    });
    //isLoadingUpdate(false);
    Navigator.pop(context);
  }

  void generateSingleAlarm(Configuration configuration,
      Function isLoadingUpdate, int weekDay, Day day, Lesson lesson) async {
    isLoadingUpdate(true);

    double preparationAndTransportTime = duration.inMinutes / 60;

    double alarmTime = lesson.start - preparationAndTransportTime;
    int hour = alarmTime.round();
    int minutes =
        (double.parse(".${alarmTime.toString().split('.')[1]}") * 60).round();

    final AndroidIntent intent = AndroidIntent(
      action: 'android.intent.action.SET_ALARM',
      arguments: <String, dynamic>{
        'android.intent.extra.alarm.DAYS': <int>[weekDay + 1],
        'android.intent.extra.alarm.HOUR': hour,
        'android.intent.extra.alarm.MINUTES': minutes,
        'android.intent.extra.alarm.SKIP_UI': !openClockAppAfterGeneration,
        'android.intent.extra.alarm.MESSAGE':
            "Cours en salle ${lesson.room} (${lesson.subject})",
      },
    );
    intent.launch();

    isLoadingUpdate(false);
  }

  Widget showOptionWidget(BuildContext context, String label, bool value,
      void onChanged(newValue), Color firstColor) {
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
}
