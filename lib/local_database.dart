import 'package:sqflite/sqflite.dart';
import 'package:vge/day.dart';
import 'package:path/path.dart' as p;

const schedulerCacheTableName = 'schedulerCache';

const day = 'day';
const savingDate = 'savingDate';
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
          'CREATE TABLE $schedulerCacheTableName ($day INTEGER, $savingDate INTEGER, $startTime TEXT, $endTime TEXT, $room TEXT, $subject TEXT, $professor TEXT)');
    });
  }

  Future addDay(Day _day) async {
    DateTime currentTime = DateTime.now();
    await schedulerCache.transaction((txn) async {
      _day.rawLessons.forEach((Lesson lesson) async {
        await txn.rawInsert('INSERT INTO $schedulerCacheTableName '
            '($day, $savingDate, $startTime, $endTime, $room, $subject, $professor) '
            'VALUES (${dateTimeToId(_day.date)}, ${currentTime.millisecondsSinceEpoch}, "${lesson.startTime}", "${lesson.endTime}", "${lesson.room}", "${lesson.subject}", "${lesson.professor}")');
        print(
            'VALUES (${dateTimeToId(_day.date)}, ${currentTime.millisecondsSinceEpoch}, "${lesson.startTime}", "${lesson.endTime}", "${lesson.room}", "${lesson.subject}", "${lesson.professor}")');
      });
      if(_day.rawLessons.length == 0){
        await txn.rawInsert('INSERT INTO $schedulerCacheTableName '
            '($day, $savingDate) '
            'VALUES (${dateTimeToId(_day.date)}, ${currentTime.millisecondsSinceEpoch})');
      }
    });
  }

  Future<Day> getDay(DateTime dateTime) async {
    List<Map> dataList = await schedulerCache.rawQuery(
        'SELECT * FROM $schedulerCacheTableName WHERE $day = ${dateTimeToId(dateTime)}');
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

  Future deleteDay(Day _day) async {
    await schedulerCache.rawDelete(
        'DELETE FROM $schedulerCacheTableName WHERE $day = ${dateTimeToId(_day.date)}');
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
