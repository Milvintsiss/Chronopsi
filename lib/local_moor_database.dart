import 'package:vge/moor_database.dart';

import 'day.dart' as d;

class LocalMoorDatabase {
  AppMoorDatabase moorDatabase = AppMoorDatabase();

  Future addDay(d.Day _day, String logIn) async {
    DateTime currentTime = DateTime.now();
    _day.rawLessons.forEach((d.Lesson lesson) async {
      await moorDatabase.insertDay(Lesson(
        day: dateTimeToId(_day.date),
        savingDate: currentTime.millisecondsSinceEpoch,
        logIn: logIn,
        startTime: lesson.startTime,
        endTime: lesson.endTime,
        room: lesson.room,
        subject: lesson.subject,
        professor: lesson.professor,
      ));
    });

    if(_day.rawLessons.isEmpty){
      await moorDatabase.insertDay(Lesson(
        day: dateTimeToId(_day.date),
        savingDate: currentTime.millisecondsSinceEpoch,
        logIn: logIn,
      ));
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
          savingDate: DateTime.fromMillisecondsSinceEpoch(element.savingDate),
        ));
      });
      return d.Day(date: dateTime, rawLessons: lessons);
    } else {
      return null;
    }
  }

  Future deleteDay(d.Day _day, String logIn) async {
    await moorDatabase.deleteDay(dateTimeToId(_day.date), logIn);
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
