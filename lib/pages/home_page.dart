import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vge/main.dart';
import 'package:calendar_strip/calendar_strip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vge/library/about.dart';
import 'package:vge/library/configuration.dart';
import 'package:vge/pages/settings_page.dart';
import '../app_state_notifier.dart';
import '../database.dart';
import '../day.dart';
import 'connection_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key, this.configuration}) : super(key: key);

  final Configuration configuration;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  String test = "test";
  Day day;

  DateTime selectedDay = DateTime.now().hour >= 19
      ? DateTime.now().add(Duration(days: 1))
      : DateTime.now();

  @override
  void initState() {
    super.initState();
    getDay();
  }

  Future getDay() async {
    day = await Database().getDay(widget.configuration.logIn,
        Database().convertDateTimeToMMJJAAAAString(selectedDay));
    day.init(widget.configuration.concatenateSimilarLessons);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: appBar(),
      drawer: drawer(),
      body: body(),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: Center(child: Text('Chronopsi')),
    );
  }

  Drawer drawer() {
    return Drawer(
      elevation: 10,
      child: Container(
        color: Theme.of(context).primaryColorDark,
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: ClipRRect(
                    child: Image.asset('assets/epsiLogo.png'),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  )),
                  Padding(padding: EdgeInsets.only(top: 3)),
                  Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                            color: Theme.of(context).primaryColorLight,
                            width: 3),
                      ),
                      child: Text(
                        widget.configuration.logIn,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight),
                      )),
                ],
              ),
            ),
            kDebugMode ? showListTile("Test", Icons.sort, "test") : Container(),
            kDebugMode ? showListTile("Test2", Icons.sort, "test2") : Container(),
            showListTile("Changer d'identifiants", Icons.power_settings_new,
                "switchLogIn"),
            showListTile("Options", Icons.settings, 'settings'),
            showListTile("A propos", Icons.info_outline, 'about'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Light:",
                  style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: !Provider.of<AppStateNotifier>(context).isDarkMode,
                  onChanged: (boolVal) {
                    Provider.of<AppStateNotifier>(context)
                        .updateTheme(!boolVal);
                    widget.configuration.sharedPreferences
                        .setBool('theme', !boolVal);
                  },
                  activeColor: Theme.of(context).primaryColor,
                  inactiveThumbColor: Theme.of(context).primaryColorLight,
                  inactiveTrackColor: Theme.of(context).primaryColor,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget showListTile(String title, IconData icon, String function) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).primaryColorLight,
                width: 2,
                style: BorderStyle.solid),
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(
                color: Theme.of(context).primaryColorLight, fontSize: 18),
          ),
          leading: Icon(
            icon,
            color: Theme.of(context).primaryColorLight,
          ),
          onTap: () async {
            switch (function) {
              case "switchLogIn":
                {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LogInPage(
                                configuration: widget.configuration,
                              )));
                }
                break;
              case 'settings':
                {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SettingsPage(
                                configuration: widget.configuration,
                              )));
                  getDay();
                }
                break;
              case "about":
                {
                  Navigator.pop(context);
                  aboutDialog(context, widget.configuration);
                }
                break;
              case "test":
                {
                  print(double.parse(".${(0.25).toString().split('.')[1]}") * 60);
                }
                break;
              case "test2":
                {
                  final AndroidIntent intent = const AndroidIntent(
                    action: 'android.intent.action.SET_ALARM',
                    arguments: <String, dynamic>{
                      'android.intent.extra.alarm.DAYS': <int>[2, 3, 4, 5, 6],
                      'android.intent.extra.alarm.HOUR': 22,
                      'android.intent.extra.alarm.MINUTES': 30,
                      'android.intent.extra.alarm.SKIP_UI': true,
                      'android.intent.extra.alarm.MESSAGE': 'Chronopsi',
                    },
                  );
                  intent.launch();
                }
                break;
            }
          },
        ),
      ),
    );
  }

  Widget body() {
    return Stack(
      children: [
        showEDTDay(),
        showDaySwitcher(),
      ],
    );
  }

  Widget showEDTDay() {
    if (loading)
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColorLight),
        ),
      );
    else
      return ListView(
        padding: const EdgeInsets.only(top: 100, left: 5, right: 5),
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                showHours(),
                showLessons(),
              ],
            ),
          ),
        ],
      );
  }

  Widget showLessons() {
    return Padding(
      padding: EdgeInsets.only(
          top: 2.0,
          left: MediaQuery.of(context).size.width / 6,
          right: MediaQuery.of(context).size.width / 20),
      child: Stack(children: [
        for (var i = 0; i < day.lessons.length; i++)
          Padding(
            padding: EdgeInsets.only(
                top: (day.lessons[i].start - 8) /
                    2 *
                    (MediaQuery.of(context).size.height / 7 + 4)),
            child: InkWell(
              child: Container(
                padding: EdgeInsets.all(4),
                height: (day.lessons[i].end - day.lessons[i].start) /
                    2 *
                    MediaQuery.of(context).size.height /
                    7,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                    color: Theme.of(context).primaryColorDark,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
                                  color: Theme.of(context).primaryColorLight,
                                ),
                                padding: EdgeInsets.all(6),
                                child: Text(
                                  day.lessons[i].subject,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                )),
                          ),
                          Flexible(
                            flex: 0,
                            child: Text(
                              day.lessons[i].room,
                              maxLines: 1,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      (day.lessons[i].end - day.lessons[i].start) / 2 >= 1
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  day.lessons[i].professor,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      fontSize: 11),
                                ),
                                Text(
                                  "${day.lessons[i].startTime} -> ${day.lessons[i].endTime}",
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorLight),
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
              onTap: (day.lessons[i].end - day.lessons[i].start) / 2 >= 1
                  ? null
                  : () {
                      showDialogLesson(day.lessons[i]);
                    },
            ),
          )
      ]),
    );
  }

  Widget showHours() {
    return Stack(
      children: [
        ListView.builder(
            physics: ScrollPhysics(),
            itemCount: 5,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 25),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  height: MediaQuery.of(context).size.height / 7,
                  child: Divider(
                    color: Theme.of(context).primaryColorLight,
                    thickness: 2,
                  ),
                ),
              );
            }),
        ListView.builder(
            physics: ScrollPhysics(),
            itemCount: 6,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(2),
                child: Stack(
                  overflow: Overflow.visible,
                  children: [
                    Container(
                      color: Colors.transparent,
                      height: MediaQuery.of(context).size.height / 7,
                    ),
                    Positioned(
                      left: 10,
                      top: -15,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorLight,
                            borderRadius:
                                BorderRadius.all(Radius.circular(100))),
                        child: Center(
                          child: Text(
                            (index * 2 + 8).toString(),
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                    ),
                    index == 5 || widget.configuration.cleanDisplay
                        ? Container()
                        : Positioned(
                            left: 10,
                            top: MediaQuery.of(context).size.height / 20,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorLight,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100))),
                              child: Center(
                                child: Text(
                                  (index * 2 + 9).toString(),
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              );
            })
      ],
    );
  }

  void showDialogLesson(Lesson lesson) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.transparent,
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 4 / 5,
                child: Container(
                    padding: EdgeInsets.all(4),
                    height: (lesson.end - lesson.start) *
                        MediaQuery.of(context).size.height /
                        7,
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                          color: Theme.of(context).primaryColorDark,
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(100)),
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                        ),
                                        padding: EdgeInsets.all(6),
                                        child: Text(
                                          lesson.subject,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        )),
                                  ),
                                  Flexible(
                                    flex: 0,
                                    child: Text(
                                      lesson.room,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    lesson.professor,
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        fontSize: 11),
                                  ),
                                  Text(
                                    "${lesson.startTime} -> ${lesson.endTime}",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorLight),
                                  ),
                                ],
                              )
                            ]))),
              ),
            ));
  }

  Widget showDaySwitcher() {
    return CalendarStrip(
      startDate: selectedDay.subtract(Duration(days: 300)),
      endDate: selectedDay.add(Duration(days: 300)),
      selectedDate: selectedDay,
      selectedColor: Theme.of(context).primaryColor,
      onDateSelected: (date) async {
        setState(() {
          loading = true;
        });
        selectedDay = date;
        await getDay();
      },
      addSwipeGesture: true,
      iconColor: Colors.black87,
      containerDecoration: BoxDecoration(color: Colors.black12),
      dayLabels: ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"],
      monthLabels: [
        "Janvier",
        "Février",
        "Mars",
        "Avril",
        "Mai",
        "Juin",
        "Juillet",
        "Août",
        "Septembre",
        "Octobre",
        "Novembre",
        "Décembre"
      ],
    );
  }
}
