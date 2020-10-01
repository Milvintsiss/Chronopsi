import 'package:calendar_strip/calendar_strip.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_state_notifier.dart';
import '../database.dart';
import '../day.dart';
import 'connection.dart';

class Home extends StatefulWidget {
  const Home({Key key, this.logIn}) : super(key: key);

  final String logIn;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool loading = true;
  String test = "test";
  Day day;

  DateTime selectedDay = DateTime.now();

  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    getDay();
    initSharedPreferences();
  }

  Future getDay() async {
    day = await Database()
        .getDay(widget.logIn, convertDateTimeToMMJJAAAAString(selectedDay));
    day.init();
    setState(() {
      loading = false;
    });
  }

  void initSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
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
                        widget.logIn,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight),
                      )),
                ],
              ),
            ),
            //showListTile("Test", Icons.sort, "test"),
            //showListTile("Test2", Icons.sort, "test2"),
            showListTile("Changer de logIn", Icons.power_settings_new,
                "switchConnection"),
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
                    sharedPreferences.setBool('theme', !boolVal);
                  },
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
              case "switchConnection":
                {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Connection()));
                }
                break;
              case "test":
                {
                  Day day = await Database().getDay(widget.logIn, "09/29/2020");
                  setState(() {
                    test = day.data;
                  });
                  day.init();
                }
                break;
              case "test2":
                {}
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
        child: CircularProgressIndicator(),
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
                          Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                                color: Theme.of(context).primaryColorLight,
                              ),
                              padding: EdgeInsets.all(6),
                              child: Text(
                                day.lessons[i].subject,
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              )),
                          Expanded(
                            child: Center(
                              child: Text(
                                day.lessons[i].room,
                                softWrap: false,
                                maxLines: 1,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
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
    return ListView.builder(
        physics: ScrollPhysics(),
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height / 60,
                  horizontal: MediaQuery.of(context).size.width / 25),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              height: MediaQuery.of(context).size.height / 7,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
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
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorLight,
                            borderRadius:
                                BorderRadius.all(Radius.circular(100))),
                        child: Center(
                          child: Text(
                            (index * 2 + 10).toString(),
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                      child: Divider(
                    color: Theme.of(context).primaryColorLight,
                    thickness: 2,
                  ))
                ],
              ),
            ),
          );
        });
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
                                  Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100)),
                                        color:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                      padding: EdgeInsets.all(6),
                                      child: Text(
                                        lesson.subject,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      )),
                                  Text(
                                    lesson.room,
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
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
        selectedDay = date;
        await getDay();
        setState(() {});
      },
      addSwipeGesture: true,
      iconColor: Colors.black87,
      containerDecoration: BoxDecoration(color: Colors.black12),
    );
  }

  String convertDateTimeToMMJJAAAAString(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }
}
