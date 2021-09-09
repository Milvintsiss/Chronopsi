import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:chronopsi/library/configuration.dart';

import 'API.dart';
import 'library/day.dart';

class Database {
  Future<Day> getDay(
      {@required Configuration configuration,
      @required DateTime dateTime,
      bool fromAPI = false}) async {
    Day day;
    if (fromAPI) {
      day = await BeecomeAPI.getDayFromBeecome(configuration, dateTime);
    } else {
      day = await configuration.localMoorDatabase
              .getDay(dateTime, configuration.logIn) ??
          await BeecomeAPI.getDayFromBeecome(configuration, dateTime);
    }
    //if the cache is too old, get new data from API
    if (day.rawLessons.length > 0 &&
        day.rawLessons[0].savingDate != null &&
        day.rawLessons[0].savingDate.difference(DateTime.now()).inDays >=
            configuration.cacheKeepingDuration) {
      day = await BeecomeAPI.getDayFromBeecome(configuration, dateTime);
    }
    print("lessons: ${day.rawLessons.length}");
    return day;
  }

  Stream<DayStreamValue> watchDay(
      {@required Configuration configuration,
      @required DateTime dateTime,
      bool fromAPI = false}) async* {
    Future<Day> dayFromBeecome =
        BeecomeAPI.getDayFromBeecome(configuration, dateTime);
    Day preDay = await configuration.localMoorDatabase
        .getDay(dateTime, configuration.logIn);
    if (preDay == null ||
        preDay.rawLessons[0].savingDate.difference(DateTime.now()).inDays >=
            configuration.cacheKeepingDuration)
      yield DayStreamValue(
          streamStatus: DayStreamStatus.TEMP_RESULT,
          day: await WigorAPI.getDayFromAPI(configuration, dateTime));
    else
      yield DayStreamValue(
          streamStatus: DayStreamStatus.TEMP_RESULT, day: preDay);
    Day result = await dayFromBeecome;
    yield DayStreamValue(
        streamStatus:
            result != null ? DayStreamStatus.RESULT : DayStreamStatus.ERROR,
        day: result);
  }
}

class DayStreamValue {
  DayStreamStatus streamStatus;
  Day day;

  DayStreamValue({@required this.streamStatus, @required this.day});
}

enum DayStreamStatus {
  TEMP_RESULT,
  RESULT,
  ERROR,
}
