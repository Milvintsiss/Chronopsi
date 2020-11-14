import 'dart:io';
import 'dart:ui';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vge/library/about.dart';
import 'package:vge/library/alarm_generation.dart';
import 'package:vge/library/configuration.dart';
import 'package:vge/library/custom_calendar_strip.dart';
import 'package:vge/library/date_utils.dart';
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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  String test = "test";
  Day day;

  int swipeValue = 1;

  DateTime selectedDay = DateTime.now().hour >= 19
      ? DateTime.now().add(Duration(days: 1))
      : DateTime.now().add(Duration(days: 0));

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
      isLoading = false;
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
                  Padding(padding: EdgeInsets.only(top: 3)),
                  Text(
                    "Identifiants:",
                    style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontSize: 16),
                  ),
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
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                ],
              ),
            ),
            kDebugMode
                ? showListTile("Test", Icons.sort, onTap: () {})
                : Container(),
            kDebugMode
                ? showListTile("Test2", Icons.sort, onTap: () {})
                : Container(),
            showListTile("Actualiser", Icons.refresh, onTap: () {
              Navigator.pop(context);
              setState(() {
                isLoading = true;
              });
              getDay();
            }),
            showListTile("Changer d'identifiants", Icons.power_settings_new,
                onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LogInPage(
                            configuration: widget.configuration,
                          )));

              Navigator.pop(context);
            }),
            showListTile("Options", Icons.settings, onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingsPage(
                            configuration: widget.configuration,
                          )));
              Navigator.pop(context);
              getDay();
            }),
            showListTile("A propos", Icons.info_outline, onTap: () {
              Navigator.pop(context);
              aboutDialog(context, widget.configuration);
            }),
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

  Widget showListTile(String title, IconData icon, {Function onTap}) {
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
          onTap: onTap,
        ),
      ),
    );
  }

  Widget body() {
    return Stack(
      children: [
        showEDTDay(),
        showDaySwitcher(),
        showGoToNextLessonButton(),
      ],
    );
  }

  Widget showEDTDay() {
    return GestureDetector(
      onHorizontalDragEnd: onSwipeLeftOrRight,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(top: 100, left: 5, right: 5),
            physics:
                AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    showHours(),
                    isLoading
                        ? Align(
                            alignment: Alignment.topCenter,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColorLight),
                            ),
                          )
                        : showLessons(),
                  ],
                ),
              ),
            ],
          ),
          showOpacityLayerIfNoLesson(),
          showNoLessonAvailableTextIfNoLesson(),
        ],
      ),
    );
  }

  // void onSwipeLeftOrRight(int index) {
  //   setState(() {
  //     selectedDay = selectedDay.add(Duration(days: index - swipeValue));
  //     isLoading = true;
  //   });
  //   getDay();
  //   swipeValue = index;
  // }

  void onSwipeLeftOrRight(DragEndDetails dragEndDetails) {
    int nextOrPreviousDay = 0;
    if (dragEndDetails.primaryVelocity > 750) {
      nextOrPreviousDay = -1;
    } else if (dragEndDetails.primaryVelocity < -750) {
      nextOrPreviousDay = 1;
    }
    if (nextOrPreviousDay != 0) {
      setState(() {
        selectedDay = selectedDay.add(Duration(days: nextOrPreviousDay));
        isLoading = true;
      });
      getDay();
    }
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
              child: Hero(
                tag: day.lessons[i].startTime,
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
                                        color:
                                            Theme.of(context).primaryColorDark,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                        color: Theme.of(context)
                                            .primaryColorLight),
                                  ),
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
              onTap: () => showDialogLesson(day.lessons[i]),
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
                  clipBehavior: Clip.none,
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
              elevation: 0,
              backgroundColor: Colors.transparent,
              content: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  border: Border.all(
                      color: Theme.of(context).primaryColorDark, width: 4),
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: lesson.startTime,
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          height: MediaQuery.of(context).size.height / 7,
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
                                          color: Theme.of(context)
                                              .primaryColorLight,
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
                              ])),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                      child: Column(
                        children: [
                          showTeamsButton(),
                          Platform.isAndroid
                              ? showGenerateAlarmButton(lesson)
                              : Container(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  Widget showTeamsButton() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(100))),
      color: Colors.blue[800],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 42, child: Image.asset('assets/teamsLogo.png')),
          Text(
            "Teams",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
      onPressed: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Disponible dans une prochaine MAJ",
            style: TextStyle(color: Colors.red),
          ),
        ));
      },
    );
  }

  Widget showGenerateAlarmButton(Lesson lesson) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(100))),
      color: Theme.of(context).primaryColorDark,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
              child: Icon(
                Icons.alarm,
                color: Theme.of(context).primaryColorLight,
              ),
            ),
            Container(width: 10),
            Expanded(
              child: Text(
                "Génerer une alarme pour ce cours",
                maxLines: 2,
                style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
        AlarmGeneration().showGenerateAlarmsDialog(
          context,
          widget.configuration,
          isLoadingUpdate: (bool loading){},
          day: day,
          lesson: lesson,
          weekDay: selectedDay.weekday,
        );
      },
    );
  }

  Widget showDaySwitcher() {
    return CustomCalendarStrip(
      startDate: selectedDay.subtract(Duration(days: 300)),
      endDate: selectedDay.add(Duration(days: 300)),
      selectedDate: selectedDay,
      selectedColor: Theme.of(context).primaryColor,
      onDateSelected: (date) async {
        setState(() {
          isLoading = true;
        });
        selectedDay = date;
        await getDay();
      },
      addSwipeGesture: true,
      iconColor: Theme.of(context).primaryColorLight,
      containerDecoration:
          BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.3)),
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

  Widget showGoToNextLessonButton() {
    if (!isLoading && day.lessons.length == 0)
      return Positioned(
        bottom: 15,
        left: 20,
        right: 20,
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
          child: Center(child: Text("Aller aux prochains cours")),
          onPressed: goToNextLesson,
        ),
      );
    else
      return Container();
  }

  Widget showOpacityLayerIfNoLesson() {
    if (!isLoading && day.lessons.length == 0)
      return Opacity(
        opacity: 0.7,
        child: Container(
          color: Theme.of(context).primaryColor,
        ),
      );
    else
      return Container();
  }

  Widget showNoLessonAvailableTextIfNoLesson() {
    if (!isLoading && day.lessons.length == 0)
      return Center(
        child: Text(
          "Pas de cours ce jour-ci.",
          style: TextStyle(color: Theme.of(context).primaryColorLight),
        ),
      );
    else
      return Container();
  }

  void goToNextLesson() async {
    setState(() {
      isLoading = true;
    });
    while (day.lessons.length == 0) {
      //repeat while there is no lessons for the selected day
      setState(() {
        selectedDay = selectedDay.add(Duration(days: 1));
      });
      day = await Database().getDay(widget.configuration.logIn,
          Database().convertDateTimeToMMJJAAAAString(selectedDay));
      day.init(widget.configuration.concatenateSimilarLessons);
    }
    setState(() {
      isLoading = false;
    });
  }
}
