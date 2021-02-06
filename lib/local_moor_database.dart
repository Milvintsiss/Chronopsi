import 'package:flutter/foundation.dart';
import 'package:chronopsi/moor_database.dart';

import 'library/day.dart' as d;
import 'library/calendarDay.dart' as c;

class LocalMoorDatabase {
  AppMoorDatabase moorDatabase = AppMoorDatabase();

  Future addDay(d.Day _day, String logIn) async {
    await deleteDay(_day, logIn);
    DateTime currentTime = DateTime.now();
    if (_day.rawLessons.isEmpty) {
      await moorDatabase.insertLesson(Lesson(
        day: dateTimeToId(_day.date),
        savingDate: currentTime.millisecondsSinceEpoch,
        logIn: logIn,
      ));
    } else {
      List<Lesson> lessons = [];
      _day.rawLessons.forEach((d.Lesson lesson) {
        lessons.add(Lesson(
          day: dateTimeToId(_day.date),
          savingDate: currentTime.millisecondsSinceEpoch,
          logIn: logIn,
          startTime: lesson.startTime,
          endTime: lesson.endTime,
          room: lesson.room,
          subject: lesson.subject,
          professor: lesson.professor,
          wasAbsent: lesson.wasAbsent,
        ));
      });
      await moorDatabase.insertLessons(lessons);
    }
  }

  Future<d.Day> getDay(DateTime dateTime, String logIn) async {
    List<Lesson> dataList =
    await moorDatabase.getLessonsByDay(dateTimeToId(dateTime), logIn);
    if (dataList.length > 0) {
      List<d.Lesson> lessons = [];
      dataList.forEach((element) {
        lessons.add(d.Lesson(
          element.startTime,
          element.endTime,
          element.room,
          element.subject,
          element.professor,
          wasAbsent: element.wasAbsent,
          savingDate: DateTime.fromMillisecondsSinceEpoch(element.savingDate),
        ));
      });
      return d.Day(date: dateTime, rawLessons: lessons);
    } else {
      return null;
    }
  }

  Stream<d.Day> watchDay(DateTime dateTime, String logIn) async* {
    Stream<List<Lesson>> lessonsOfDayStream = moorDatabase
        .watchLessonsByDay(dateTimeToId(dateTime), logIn);

    await for (List<Lesson> lessons in lessonsOfDayStream){
    if (lessons.length > 0) {
      List<d.Lesson> _lessons = [];
      lessons.forEach((element) {
        _lessons.add(d.Lesson(
          element.startTime,
          element.endTime,
          element.room,
          element.subject,
          element.professor,
          wasAbsent: element.wasAbsent,
          savingDate: DateTime.fromMillisecondsSinceEpoch(element.savingDate),
        ));
      });
      yield d.Day(date: dateTime, rawLessons: _lessons);
    }
  }
  }

  Future deleteDay(d.Day _day, String logIn) async {
    await moorDatabase.deleteDay(dateTimeToId(_day.date), logIn);
  }

  Future deleteAllDays() async {
    await moorDatabase.deleteAllDays();
  }

  Future addDays(List<d.Day> _days, String logIn) async {
    List<Lesson> lessons = [];
    for (d.Day _day in _days) {
      await deleteDay(_day, logIn);
      DateTime currentTime = DateTime.now();
      if (_day.rawLessons.isEmpty) {
        lessons.add(Lesson(
          day: dateTimeToId(_day.date),
          savingDate: currentTime.millisecondsSinceEpoch,
          logIn: logIn,
        ));
      } else {
        _day.rawLessons.forEach((d.Lesson lesson) {
          lessons.add(Lesson(
            day: dateTimeToId(_day.date),
            savingDate: currentTime.millisecondsSinceEpoch,
            logIn: logIn,
            startTime: lesson.startTime,
            endTime: lesson.endTime,
            room: lesson.room,
            subject: lesson.subject,
            professor: lesson.professor,
            wasAbsent: lesson.wasAbsent,
          ));
        });
      }
    }
    await moorDatabase.insertLessons(lessons);
  }

  Future addCalendarDays(List<c.CalendarDay> _calendarDays,
      String logIn) async {
    await moorDatabase.deleteAllCalendarDays(logIn);
    DateTime currentTime = DateTime.now();
    List<CalendarDay> calendarDays = [];
    _calendarDays.forEach((_day) {
      calendarDays.add(
          CalendarDay(
            day: dateTimeToId(_day.date),
            logIn: logIn,
            savingDate: currentTime.millisecondsSinceEpoch,
            state: dayStateToString(_day.dayState),
          )
      );
    });
    await moorDatabase.insertCalendarDays(calendarDays);
  }

  Future<List<c.CalendarDay>> getAllCalendarDays(String logIn) async {
    List<CalendarDay> calendarDays = await moorDatabase.getAllCalendarDays(
        logIn);
    List<c.CalendarDay> _calendarDays = [];
    calendarDays.forEach((calendarDay) {
      _calendarDays.add(
          c.CalendarDay(
            idToDateTime(calendarDay.day),
            dayStateFromString(calendarDay.state),
            savingDate: DateTime.fromMillisecondsSinceEpoch(
                calendarDay.savingDate),
          )
      );
    });
    return _calendarDays;
  }

  Stream<List<c.CalendarDay>> watchAllCalendarDays(String logIn) async* {
    Stream<List<CalendarDay>> calendarDaysStream = moorDatabase
        .watchAllCalendarDays(logIn);

    await for (List<CalendarDay> calendarDays in calendarDaysStream) {
      if (calendarDays.length > 0) {
        List<c.CalendarDay> _calendarDays = [];
        calendarDays.forEach((calendarDay) {
          _calendarDays.add(
              c.CalendarDay(
                idToDateTime(calendarDay.day),
                dayStateFromString(calendarDay.state),
                savingDate: DateTime.fromMillisecondsSinceEpoch(
                    calendarDay.savingDate),
              )
          );
        });
        yield _calendarDays;
      }
    }
  }
}

int dateTimeToId(DateTime dateTime) {
  String day = dateTime.day.toString().length == 1
      ? "0${dateTime.day.toString()}"
      : dateTime.day.toString();
  String month = dateTime.month.toString().length == 1
      ? "0${dateTime.month.toString()}"
      : dateTime.month.toString();
  return int.parse(dateTime.year.toString() + day + month);
}

DateTime idToDateTime(int id) {
  return DateTime(
      int.parse(id.toString().substring(0, 4)),
      int.parse(id.toString().substring(6, 8)),
      int.parse(id.toString().substring(4, 6)));
}

bool isSameDay(DateTime firstDate, DateTime secondDate) {
  return firstDate.year == secondDate.year &&
      firstDate.month == secondDate.month &&
      firstDate.day == secondDate.day;
}

String dayStateToString(c.DayState dayState){
  return describeEnum(dayState);
}

c.DayState dayStateFromString(String dayState){
  return c.DayState.values.firstWhere((element) => describeEnum(element) == dayState);
}