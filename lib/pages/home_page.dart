import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:calendar_strip/calendar_strip.dart';
import 'package:chronopsi/library/calendarDay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:chronopsi/library/about.dart';
import 'package:chronopsi/library/alarm_generation.dart';
import 'package:chronopsi/library/configuration.dart';
import 'package:chronopsi/library/justifyAbsence.dart';
import 'package:chronopsi/library/teamsUtils.dart';
import 'package:chronopsi/pages/settings_page.dart';
import '../database.dart';
import '../library/day.dart';
import '../local_moor_database.dart';
import '../myLearningBoxAPI.dart';
import 'calendar_page.dart';
import 'connection_page.dart';
import 'grades_page.dart';

const Color absColor = Color.fromRGBO(139, 0, 0, 1);
const Color absColorText = Color.fromRGBO(255, 69, 0, 1);

class HomePage extends StatefulWidget {
  const HomePage({Key key, this.configuration}) : super(key: key);

  final Configuration configuration;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  bool isLoadingForBeecome = true;
  Day day;

  Timer errorTimer;

  StreamSubscription<Day> dayStream;

  int swipeValue = 1;

  DateTime selectedDay = DateTime.now().hour >= 19
      ? DateTime.now().add(Duration(days: 1))
      : DateTime.now();

  @override
  void initState() {
    listenDay();
    super.initState();
  }

  @override
  void dispose() {
    if (errorTimer != null) errorTimer.cancel();
    dayStream.cancel();
    super.dispose();
  }

  void listenDay() async {
    if (errorTimer != null) errorTimer.cancel();
    errorTimer = Timer(Duration(seconds: 10), () {
      if (isLoadingForBeecome) widget.configuration.error(context);
    });

    bool yieldedNull = false;
    setState(() {
      isLoading = true;
      isLoadingForBeecome = true;
    });
    if (dayStream != null) dayStream.cancel();
    dayStream = Database()
        .watchDay(configuration: widget.configuration, dateTime: selectedDay)
        .listen((_day) {
      if (_day != null) {
        day = _day;
        day.init(widget.configuration.concatenateSimilarLessons);
        setState(() {
          if (yieldedNull) {
            isLoading = false;
            isLoadingForBeecome = false;
          } else
            isLoading = false;
        });
      } else {
        yieldedNull = true;
      }
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
      title: !Platform.isWindows
          ? Center(
              child: Text(
              'Chronopsi',
            ))
          : null,
      actions: [
        IconButton(
          icon: Icon(MdiIcons.microsoftTeams),
          onPressed: () {
            openTeams(context);
          },
        ),
        Platform.isAndroid
            ? IconButton(
                icon: Icon(Icons.alarm),
                onPressed: () => AlarmGeneration()
                    .showGenerateAlarmsDialog(context, widget.configuration),
              )
            : Container(),
        isLoadingForBeecome
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.5),
                child: Center(
                  child: SizedBox(
                    width: 15,
                    height: 15,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColorLight),
                      ),
                    ),
                  ),
                ),
              )
            : IconButton(
                icon: Icon(
                  Boxicons.bx_calendar_check,
                ),
                tooltip: "L'emploi du temps est à jour!",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      "L'emploi du temps est à jour!",
                      style: TextStyle(color: Colors.green),
                    ),
                  ));
                },
              ),
      ],
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )),
                ],
              ),
            ),
            kDebugMode
                ? showListTile("Test", Icons.sort, onTap: () {
                    getGradesFromMyLearningBox(widget.configuration);
                  })
                : Container(),
            kDebugMode
                ? showListTile("Test2", Icons.sort, onTap: () {
                    widget.configuration.localMoorDatabase.deleteAllDays();
                  })
                : Container(),
            // showListTile("Actualiser", Icons.refresh, onTap: () {
            //   Navigator.pop(context);
            //   setState(() {
            //     isLoading = true;
            //   });
            //   getDay(fromAPI: true);
            // }),
            showListTile("Calendrier", Icons.calendar_today_rounded,
                onTap: () async {
              DateTime date = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CalendarPage(
                            configuration: widget.configuration,
                          )));
              Navigator.pop(context);
              if (date != null) {
                selectedDay = date;
                listenDay();
              }
            }),
            showListTile("Notes", MdiIcons.schoolOutline, onTap: () async {
              if (widget.configuration.password != null) {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GradesPage(
                              configuration: widget.configuration,
                            )));
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    "Vous devez avoir enregistré votre mot de passe pour accéder "
                    "à cette fonctionnalité!",
                    style: TextStyle(color: Colors.red),
                  ),
                ));
              }
            }),
            showListTile("Changer d'identifiants", MdiIcons.loginVariant,
                onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LogInPage(
                            configuration: widget.configuration,
                          )));

              Navigator.pop(context);
            }),
            showListTile("Options", Icons.settings_outlined, onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingsPage(
                            configuration: widget.configuration,
                          )));
              Navigator.pop(context);
              listenDay();
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
                  value: !widget.configuration.isDarkTheme,
                  onChanged: (boolVal) {
                    setState(() {
                      widget.configuration.isDarkTheme =
                          !widget.configuration.isDarkTheme;
                    });
                    AdaptiveTheme.of(context).toggleThemeMode();
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
      });
      listenDay();
    }
  }

  Widget showLessons() {
    return Padding(
      padding: EdgeInsets.only(
          top: 2.0,
          left: MediaQuery.of(context).size.width / 9,
          right: MediaQuery.of(context).size.width / 100),
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
                      border: Border.all(
                          color: Theme.of(context).primaryColorLight),
                      color: day.lessons[i].wasAbsent
                          ? absColor
                          : Theme.of(context).primaryColorDark,
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
                                    fontSize: 16,
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
    lesson.setState(selectedDay);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 10),
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
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
                                            fontSize: 16,
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
                                ),
                                lesson.wasAbsent
                                    ? Text(
                                        "Vous avez été absent lors de ce cours!",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: absColorText),
                                      )
                                    : Text(
                                        lesson.lessonState ==
                                                LessonState.UPCOMING
                                            ? lesson.daysRemeaning > 0
                                                ? "Dans ${lesson.daysRemeaning} jours"
                                                : lesson.hoursRemeaning > 0
                                                    ? "${lesson.hoursRemeaning}h"
                                                        " et ${lesson.minRemeaning}min"
                                                        "\nrestantes avant le début du cours"
                                                    : "${lesson.minRemeaning} minutes"
                                                        "\nrestantes avant le début du cours"
                                            : lesson.lessonState ==
                                                    LessonState.CURRENT
                                                ? "En cours"
                                                : "Ce cours est passé",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12),
                                      ),
                              ])),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                      child: Column(
                        children: [
                          showTeamsButton(),
                          showOpenCalendarButton(),
                          if (Platform.isAndroid)
                            showGenerateAlarmButton(lesson),
                          if (lesson.wasAbsent)
                            showJustifyAbscenceButton(lesson),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  Widget showOpenCalendarButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.padded,
        primary: Theme.of(context).primaryColorDark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100))),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
              child: Icon(
                Icons.calendar_today_rounded,
                color: Theme.of(context).primaryColorLight,
              ),
            ),
            Container(width: 10),
            Expanded(
              child: Text(
                "Ouvrir dans le calendrier",
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
      onPressed: () async {
        Navigator.pop(context);
        DateTime date = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CalendarPage(
                      configuration: widget.configuration,
                      focusDate: selectedDay,
                    )));
        if (date != null) {
          selectedDay = date;
          listenDay();
        }
      },
    );
  }

  Widget showTeamsButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.padded,
        primary: Colors.blue[800],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100))),
      ),
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
        openTeams(context);
      },
    );
  }

  Widget showGenerateAlarmButton(Lesson lesson) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.padded,
        primary: Theme.of(context).primaryColorDark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100))),
      ),
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
          isLoadingUpdate: (bool loading) {},
          day: day,
          lesson: lesson,
          weekDay: selectedDay.weekday,
        );
      },
    );
  }

  Widget showJustifyAbscenceButton(Lesson lesson) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.padded,
          primary: Theme.of(context).primaryColorDark,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(100))),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
                child: Icon(
                  Icons.mail_outline,
                  color: Theme.of(context).primaryColorLight,
                ),
              ),
              Container(width: 10),
              Expanded(
                child: Text(
                  "Justifier cette absence",
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
          justifyAbsence(context, widget.configuration, lesson, selectedDay);
        });
  }

  Widget showDaySwitcher() {
    return CalendarStrip(
      startDate: selectedDay.subtract(Duration(days: 300)),
      endDate: selectedDay.add(Duration(days: 300)),
      selectedDate: selectedDay,
      selectedDateColor: Theme.of(context).primaryColor,
      selectedDateTextColor: Theme.of(context).primaryColorLight,
      daysTextColor: Theme.of(context).primaryColor,
      monthYearTextColor: Theme.of(context).primaryColor,
      onDateSelected: (date) async {
        selectedDay = date;
        listenDay();
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
    if (!isLoading && !isLoadingForBeecome && day.isEmpty)
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
    if (!isLoading && day.isEmpty)
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
    if (!isLoading && day.isEmpty)
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
    List<CalendarDay> calendarDays = await widget
        .configuration.localMoorDatabase
        .getAllCalendarDays(widget.configuration.logIn);

    int indexOfCurrentDay = calendarDays
        .indexWhere((calendarDay) => isSameDay(calendarDay.date, selectedDay));

    if (calendarDays[indexOfCurrentDay + 1].dayState != DayState.holiday) {
      setState(() {
        isLoading = true;
        selectedDay = calendarDays[indexOfCurrentDay + 1].date;
      });
    } else {
      for (int i = indexOfCurrentDay + 1;
          calendarDays[i].dayState == DayState.holiday &&
              i < calendarDays.length - 1;
          i++) {
        await Future.delayed(Duration(milliseconds: 100));
        setState(() {
          isLoading = true;
          selectedDay = calendarDays[i + 1].date;
        });
      }
    }

    listenDay();
  }
}

// void goToNextLesson() async {
//   Day _day = Day(date: selectedDay, rawLessons: []);
//   _day.isEmpty = true;
//   while (_day.isEmpty) {
//     //repeat while there is no lessons for the selected _day
//     setState(() {
//       isLoading = true;
//       selectedDay = selectedDay.add(Duration(days: 1));
//     });
//     _day = await Database()
//         .getDay(configuration: widget.configuration, dateTime: selectedDay);
//     _day..init(widget.configuration.concatenateSimilarLessons);
//     await Future.delayed(Duration(
//         milliseconds: 100)); //to let the time to the animation to achieve
//   }
//   day = _day;
//   listenDay();
// }
