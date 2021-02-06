import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart' as p;

import 'library/day.dart';

const schedulerCacheTableName = 'schedulerCache';

const day = 'day';
const savingDate = 'savingDate';
const logIn = 'logIn';
const startTime = 'startTime';
const endTime = 'endTime';
const room = 'room';
const subject = 'subject';
const professor = 'professor';

class LocalDatabase {
  Database schedulerCache;

  Future init() async {
    String databasesPath = await getDatabasesPath();
    String schedulerCacheDatabasePath = p.join(databasesPath, 'schedulerCache');
    schedulerCache = await openDatabase(schedulerCacheDatabasePath, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE $schedulerCacheTableName ('
              '$day INTEGER, '
              '$savingDate INTEGER, '
              '$logIn TEXT '
              '$startTime TEXT, '
              '$endTime TEXT, '
              '$room TEXT, '
              '$subject TEXT, '
              '$professor TEXT'
              ')');
    });
  }

  Future addDay(Day _day, String _logIn) async {
    DateTime currentTime = DateTime.now();
    await schedulerCache.transaction((txn) async {
      _day.rawLessons.forEach((Lesson lesson) async {
        await txn.rawInsert('INSERT INTO $schedulerCacheTableName '
            '($day, $savingDate, $logIn, $startTime, $endTime, $room, $subject, $professor) '
            'VALUES ('
            '${dateTimeToId(_day.date)}, '
            '${currentTime.millisecondsSinceEpoch}, '
            '$_logIn, '
            '"${lesson.startTime}", '
            '"${lesson.endTime}", '
            '"${lesson.room}", '
            '"${lesson.subject}", '
            '"${lesson.professor}"'
            ')');
        print(
            '$day: ${dateTimeToId(_day.date)}, '
                '$savingDate: ${currentTime.millisecondsSinceEpoch}, '
                '$logIn: $_logIn, '
                '$startTime: "${lesson.startTime}", '
                '$endTime: "${lesson.endTime}", '
                '$room: "${lesson.room}", '
                '$subject: "${lesson.subject}", '
                '$professor: "${lesson.professor}"');
      });
      if (_day.rawLessons.length == 0) {
        await txn.rawInsert('INSERT INTO $schedulerCacheTableName '
            '($day, $savingDate, $logIn) '
            'VALUES (${dateTimeToId(_day.date)}, ${currentTime.millisecondsSinceEpoch}, $_logIn)');
      }
    });
  }

  Future<Day> getDay(DateTime dateTime, String _logIn) async {
    List<Map> dataList = await schedulerCache.rawQuery(
        'SELECT * FROM $schedulerCacheTableName '
            'WHERE $day = ${dateTimeToId(dateTime)} AND $logIn = $_logIn');
    print(dataList);
    if (dataList.length > 0) {
      List<Lesson> lessons = [];
      dataList.forEach((element) {
        lessons.add(Lesson(
          element[startTime],
          element[endTime],
          element[room],
          element[subject],
          element[professor],
          savingDate: DateTime.fromMillisecondsSinceEpoch(element[savingDate]),
        ));
      });
      return Day(date: dateTime, rawLessons: lessons);
    } else
      return null;
  }

  Future deleteDay(Day _day, String _logIn) async {
    await schedulerCache.rawDelete(
        'DELETE FROM $schedulerCacheTableName '
            'WHERE $day = ${dateTimeToId(_day.date)} AND $logIn = $_logIn');
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
