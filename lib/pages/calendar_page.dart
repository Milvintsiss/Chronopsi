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

enum LoadStatus {
  LOADING,
  LOADED,
  ERROR,
}

class _CalendarPageState extends State<CalendarPage> {
  Map<DateTime, List<dynamic>> events = {};

  LoadStatus loadStatus = LoadStatus.LOADING;

  DateTime _focusedDay;

  @override
  void initState() {
    loadCalendarEvents();
    _focusedDay = widget.focusDate ?? DateTime.now();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadCalendarEvents() async {
    List<CalendarDay> calendarDays = await widget
        .configuration.localMoorDatabase
        .getAllCalendarDays(widget.configuration.logIn);
    if (calendarDays == null || calendarDays.isEmpty)
      calendarDays = await BeecomeAPI.getCalendarFromBeecome(
          widget.configuration, DateTime.now());
    if (calendarDays == null || calendarDays.isEmpty) {
      setState(() => loadStatus = LoadStatus.ERROR);
      return;
    }

    calendarDays.forEach((calendarDay) {
      events.addAll({
        calendarDay.date: [calendarDay.dayState]
      });
    });
    setState(() => loadStatus = LoadStatus.LOADED);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: appBar(),
      body: body(),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Text("Calenpsi"),
      centerTitle: true,
      actions: [
        loadStatus == LoadStatus.LOADING
            ? Padding(
                padding: const EdgeInsets.only(right: 16.5),
                child: UnconstrainedBox(
                  child: SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColorLight),
                    ),
                  ),
                ),
              )
            : loadStatus == LoadStatus.LOADED
                ? IconButton(
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
                  )
                : errorIconButton(),
      ],
    );
  }

  Widget errorIconButton({double size}) {
    return IconButton(
      iconSize: size ?? 24,
      color: Theme.of(context).primaryColorLight,
      icon: Icon(
        Boxicons.bxs_calendar_x,
      ),
      tooltip:
          "Une erreur est survenue lors du chargement de l'emploi du temps",
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Une erreur est survenue lors du chargement de l'emploi du temps",
            style: TextStyle(color: Colors.redAccent[100]),
          ),
        ));
      },
    );
  }

  Widget body() {
    return ListView(
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        loadStatus == LoadStatus.LOADING
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColorLight),
                  ),
                ),
              )
            : loadStatus == LoadStatus.LOADED
                ? calendarWidget()
                : Center(
                    child: errorIconButton(
                        size: MediaQuery.of(context).size.width / 4),
                  ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            children: [
              captionWidget("Vous avez eu une absence lors de cette journée",
                  absentColor),
              captionWidget("Vous n'avez pas cours ce jour-ci", holidayColor),
              captionWidget(
                  "Vous étiez présent lors de cette journée", presentColor),
              captionWidget("Journée de cours future", defaultColor),
            ],
          ),
        )
      ],
    );
  }

  Widget calendarWidget() {
    DateTime firstDay = DateTime.now().subtract(Duration(days: 730));
    DateTime lastDay = DateTime.now().add(Duration(days: 730));
    return TableCalendar(
      onDaySelected: (selectedDay, focusedDay) {
        Navigator.pop(context, selectedDay);
      },
      selectedDayPredicate: (day) {
        return widget.focusDate != null && isSameDay(widget.focusDate, day);
      },
      focusedDay: _focusedDay,
      onPageChanged: (date) {
        setState(() {
          _focusedDay = date;
        });
      },
      firstDay: firstDay,
      lastDay: lastDay,
      locale: 'fr_FR',
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarFormat: CalendarFormat.month,
      headerStyle: HeaderStyle(
        titleTextStyle: TextStyle(color: Theme.of(context).primaryColorLight),
        formatButtonVisible: false,
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Theme.of(context).primaryColorLight),
        weekendStyle: TextStyle(color: Colors.red[200]),
      ),
      eventLoader: (day) {
        return events[day] ?? [];
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, defaultBuilder) {
          bool isOutsideMonth = _focusedDay.month != date.month;

          date = DateTime(date.year, date.month, date.day);
          Color color = Colors.transparent;
          switch (events.containsKey(date)
              ? events[date][0] ?? DayState.undefined
              : DayState.undefined) {
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
          return Container(
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
                        ? Colors.red[200].withOpacity(isOutsideMonth ? 0.5 : 1)
                        : Theme.of(context)
                            .primaryColorLight
                            .withOpacity(isOutsideMonth ? 0.5 : 1),
                    fontSize: isOutsideMonth || d.DateUtils.isWeekend(date)
                        ? 13
                        : 16),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget captionWidget(String label, Color color) {
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
