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
}

@UseMoor(tables: [Lessons])
class AppMoorDatabase extends _$AppMoorDatabase {
  AppMoorDatabase()
      : super(LazyDatabase(() async {
          String dbFolderAndroidIOS;
          Directory dbFolderDesktop;
          if (Platform.isAndroid || Platform.isIOS) {
            dbFolderAndroidIOS = await getDatabasesPath();
            print("Save folder: $dbFolderAndroidIOS");
          } else {
            dbFolderDesktop = await getApplicationSupportDirectory();
            print("Save folder: ${dbFolderDesktop.path}");
          }
          final file = File(p.join(
              Platform.isAndroid ? dbFolderAndroidIOS : dbFolderDesktop.path,
              'lessons.sqlite'));
          return VmDatabase(file, logStatements: true);
        }));

  @override
  int get schemaVersion => 1;

  Future<List<Lesson>> getAllLessons() => select(lessons).get();

  Future<List<Lesson>> getLessonsByDay(int day, String logIn) =>
      (select(lessons)
            ..where((tbl) => tbl.day.equals(day))
            ..where((tbl) => tbl.logIn.equals(logIn)))
          .get();

  Future insertDay(Lesson lesson) => into(lessons).insert(lesson);

  Future deleteDay(int day, String logIn) => (delete(lessons)
        ..where((tbl) => tbl.day.equals(day))
        ..where((tbl) => tbl.logIn.equals(logIn)))
      .go();
}
