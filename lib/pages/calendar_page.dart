import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:chronopsi/library/calendarDay.dart';
import 'package:chronopsi/library/configuration.dart';
import 'package:chronopsi/API.dart';
import 'package:calendar_strip/date-utils.dart' as d;

final Color holidayColor = Colors.amber[400].withOpacity(0.5);
final Color absentColor = Colors.red[200].withOpacity(0.5);
final Color presentColor = Colors.green[300].withOpacity(0.5);
final Color defaultColor = Colors.blue[200].withOpacity(0.5);

class CalendarPage extends StatefulWidget {
  CalendarPage({Key key, @required this.configuration, this.focusDate})
      : super(key: key);

  final Configuration configuration;
  final DateTime focusDate;

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarController calendarController;

  Map<DateTime, List<dynamic>> events = {};

  StreamSubscription<List<CalendarDay>> calendarDaysStream;
  int streamCount = 0;

  bool isLoading = true;

  @override
  void initState() {
    calendarController = CalendarController();
    loadCalendarEvents();
    super.initState();
  }

  @override
  void dispose() {
    calendarController.dispose();
    calendarDaysStream.cancel();
    super.dispose();
  }

  void loadCalendarEvents() async {
    getCalendarFromBeecome(widget.configuration, DateTime.now());

    calendarDaysStream = widget.configuration.localMoorDatabase
        .watchAllCalendarDays(widget.configuration.logIn)
        .listen((calendarDays) {
      if (calendarDays.length > 0) {
        events.clear();
        calendarDays.forEach((calendarDay) {
          events.addAll({
            calendarDay.date: [calendarDay.dayState]
          });
        });
        streamCount++;
        if (streamCount > 1) isLoading = false;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        title: Text("Calenpsi"),
        centerTitle: true,
        actions: [
          isLoading
              ? Padding(
                padding: const EdgeInsets.only(right: 16.5),
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
                  tooltip: "Le calendrier est à jour!",
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        "Le calendrier est à jour!",
                        style: TextStyle(color: Colors.green),
                      ),
                    ));
                  },
                ),
        ],
      ),
      body: ListView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          TableCalendar(
            onDaySelected: (DateTime date, list, list2) {
              Navigator.pop(context, date);
            },
            initialSelectedDay: widget.focusDate ?? DateTime.now(),
            calendarController: calendarController,
            locale: 'fr_FR',
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: {
              CalendarFormat.month: 'Mois',
              CalendarFormat.week: 'Semaine'
            },
            headerStyle: HeaderStyle(
              titleTextStyle:
                  TextStyle(color: Theme.of(context).primaryColorLight),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: true,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle:
                  TextStyle(color: Theme.of(context).primaryColorLight),
              weekendStyle: TextStyle(color: Colors.red[200]),
            ),
            events: events,
            builders: CalendarBuilders(
              markersBuilder: (context, date, events, holidays) {
                bool isOutsideMonth =
                    calendarController.focusedDay.month != date.month;
                List<Widget> children = <Widget>[];
                Color color = Colors.transparent;
                switch (events[0]) {
                  case DayState.absent:
                    color = absentColor;
                    break;
                  case DayState.holiday:
                    color = holidayColor;
                    break;
                  case DayState.present:
                    color = presentColor;
                    break;
                  case DayState.others:
                    color = defaultColor;
                    break;
                }
                children.add(Container(
                  color: isOutsideMonth
                      ? color.withOpacity(0.15)
                      : d.DateUtils.isWeekend(date)
                          ? color.withOpacity(0.4)
                          : color,
                  width: 100,
                  height: 100,
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                          color: d.DateUtils.isWeekend(date)
                              ? Colors.red[200]
                                  .withOpacity(isOutsideMonth ? 0.5 : 1)
                              : Theme.of(context)
                                  .primaryColorLight
                                  .withOpacity(isOutsideMonth ? 0.5 : 1),
                          fontSize:
                              isOutsideMonth || d.DateUtils.isWeekend(date)
                                  ? 13
                                  : 16),
                    ),
                  ),
                ));
                return children;
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Column(
              children: [
                key("Vous avez eu une absence lors de cette journée",
                    absentColor),
                key("Vous n'avez pas cours ce jour-ci", holidayColor),
                key("Vous étiez présent lors de cette journée", presentColor),
                key("Journée de cours future", defaultColor),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget key(String label, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            color: color,
            width: 35,
            height: 35,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                label,
                style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
