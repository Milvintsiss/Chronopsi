import 'package:flutter/cupertino.dart';
import 'package:chronopsi/library/configuration.dart';

import 'API.dart';
import 'library/day.dart';

//****************************************************************************//
//TO USE SQFLITE INSTEAD OF MOOR REPLACE ALL "localMoorDatabase" with "localDatabase"
//AND UNCOMMENT SQFLITE INIT IN "root_page"
//****************************************************************************//

class Database {
  Future<Day> getDay(
      {@required Configuration configuration,
      @required DateTime dateTime,
      bool fromAPI = false}) async {
    Day day;
    if (fromAPI) {
      day = await getDayFromBeecome(configuration, dateTime);
    } else {
      day = await configuration.localMoorDatabase
              .getDay(dateTime, configuration.logIn) ??
          await getDayFromBeecome(configuration, dateTime);
    }
    //if the cache is too old, get new data from API
    if (day.rawLessons.length > 0 &&
        day.rawLessons[0].savingDate != null &&
        day.rawLessons[0].savingDate.difference(DateTime.now()).inDays >=
            configuration.cacheKeepingDuration) {
      day = await getDayFromBeecome(configuration, dateTime);
    }
    print("lessons: ${day.rawLessons.length}");
    return day;
  }

  Stream<Day> watchDay(
      {@required Configuration configuration,
      @required DateTime dateTime,
      bool fromAPI = false}) async* {
    getWeekFromBeecome(configuration, dateTime);

    Day preDay = await configuration.localMoorDatabase
        .getDay(dateTime, configuration.logIn);
    if (preDay == null ||
        preDay.rawLessons[0].savingDate.difference(DateTime.now()).inDays >=
            configuration.cacheKeepingDuration)
      yield await getDayFromAPI(configuration, dateTime);
    else
      yield preDay;

    Stream<Day> dayStream =
        configuration.localMoorDatabase.watchDay(dateTime, configuration.logIn);

    bool firstYielded = true;
    await for (Day day in dayStream) {
      if (firstYielded) {
        yield null;
        firstYielded = false;
      } else {
        if (day.rawLessons[0].savingDate != null &&
            day.rawLessons[0].savingDate.difference(DateTime.now()).inDays <
                configuration.cacheKeepingDuration) yield day;
      }
    }
  }
}
