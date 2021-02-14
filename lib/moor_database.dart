import 'dart:io';

import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:sqflite/sqflite.dart' show getDatabasesPath;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'moor_database.g.dart';

class Lessons extends Table {
  IntColumn get day => integer()();

  IntColumn get savingDate => integer()();

  TextColumn get logIn => text()();

  TextColumn get startTime => text().nullable()();

  TextColumn get endTime => text().nullable()();

  TextColumn get room => text().nullable()();

  TextColumn get subject => text().nullable()();

  TextColumn get professor => text().nullable()();

  BoolColumn get wasAbsent => boolean().nullable()();
}

class CalendarDays extends Table {
  IntColumn get day => integer()();

  IntColumn get savingDate => integer()();

  TextColumn get logIn => text()();

  TextColumn get state => text()();
}

@UseMoor(tables: [Lessons, CalendarDays])
class AppMoorDatabase extends _$AppMoorDatabase {
  AppMoorDatabase()
      : super(LazyDatabase(() async {
          String dbFolder;
          if (Platform.isAndroid || Platform.isIOS) {
            dbFolder = await getDatabasesPath();
          } else {
            final dbFolderDesktop = await getApplicationSupportDirectory();
            dbFolder = dbFolderDesktop.path;
          }
          print("Save folder: $dbFolder");
          final file = File(p.join(dbFolder, 'lessons.sqlite'));
          return VmDatabase(file, logStatements: true);
        }));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (Migrator m) {
        return m.createAll();
      }, onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1 || from == 2) {
          await m.deleteTable('Lessons');
          await m.createAll();
        }
      });

  Future createAllTablesAgain() async {
    final migrator = createMigrator();
    for (var table in allTables) {
      await customStatement('DROP TABLE ${table.actualTableName};');
      await migrator.createTable(table);
    }
  }

  Future<List<Lesson>> getAllLessons(String logIn) =>
      (select(lessons)..where((tbl) => tbl.logIn.equals(logIn))).get();

  Future<List<Lesson>> getLessonsByDay(int day, String logIn) =>
      (select(lessons)
            ..where((tbl) => tbl.day.equals(day))
            ..where((tbl) => tbl.logIn.equals(logIn)))
          .get();

  Stream<List<Lesson>> watchLessonsByDay(int day, String logIn) =>
      (select(lessons)
            ..where((tbl) => tbl.day.equals(day))
            ..where((tbl) => tbl.logIn.equals(logIn)))
          .watch();

  Future insertLesson(Lesson lesson) => into(lessons).insert(lesson);

  Future insertLessons(List<Lesson> _lessons) async =>
      await batch((batch) => batch.insertAll(lessons, _lessons));

  Future deleteDay(int day, String logIn) => (delete(lessons)
        ..where((tbl) => tbl.day.equals(day))
        ..where((tbl) => tbl.logIn.equals(logIn)))
      .go();

  Future deleteAllDays() => delete(lessons).go();

  Future<CalendarDay> getCalendarDay(int day, String logIn) =>
      (select(calendarDays)
            ..where((tbl) => tbl.day.equals(day))
            ..where((tbl) => tbl.logIn.equals(logIn)))
          .getSingle();

  Stream<CalendarDay> watchCalendarDay(int day, String logIn) =>
      (select(calendarDays)
            ..where((tbl) => tbl.day.equals(day))
            ..where((tbl) => tbl.logIn.equals(logIn)))
          .watchSingle();

  Future<List<CalendarDay>> getAllCalendarDays(String logIn) =>
      (select(calendarDays)..where((tbl) => tbl.logIn.equals(logIn))).get();

  Stream<List<CalendarDay>> watchAllCalendarDays(String logIn) =>
      (select(calendarDays)..where((tbl) => tbl.logIn.equals(logIn))).watch();

  Future insertCalendarDay(CalendarDay calendarDay) =>
      into(calendarDays).insert(calendarDay);

  Future insertCalendarDays(List<CalendarDay> _calendarDays) async =>
      await batch((batch) => batch.insertAll(calendarDays, _calendarDays));

  Future deleteCalendarDay(int day, String logIn) => (delete(calendarDays)
        ..where((tbl) => tbl.day.equals(day))
        ..where((tbl) => tbl.logIn.equals(logIn)))
      .go();

  Future deleteAllCalendarDays(String logIn) =>
      (delete(calendarDays)..where((tbl) => tbl.logIn.equals(logIn))).go();
}
