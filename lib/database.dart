import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:vge/library/configuration.dart';

import 'day.dart';

const String url =
    "http://edtmobilite.wigorservices.net/WebPsDyn.aspx?Action=posETUD&serverid=h&tel=";

//****************************************************************************//
//TO USE SQFLITE INSTEAD OF MOOR REPLACE ALL "localMoorDatabase" with "localDatabase"
//AND UNCOMMENT SQFLITE INIT IN "root_page"
//****************************************************************************//

class Database {
  Future<Day> getDay(
      {@required Configuration configuration,
      @required DateTime dateTime, bool fromAPI = false,
      String time = "8:00"}) async {
    Day day;
    if(fromAPI){
      await configuration.localMoorDatabase.deleteDay(Day(rawLessons: null, date: dateTime), configuration.logIn);
      day = await getDayFromAPI(configuration, dateTime, time: time);
    }else {
      day = await configuration.localMoorDatabase.getDay(dateTime, configuration.logIn) ??
          await getDayFromAPI(configuration, dateTime, time: time);
    }
    //if the cache is too old, get new data from API
    if (day.rawLessons.length > 0 &&
        day.rawLessons[0].savingDate != null &&
        day.rawLessons[0].savingDate.difference(DateTime.now()).inDays >= configuration.cacheKeepingDuration) {
      await configuration.localMoorDatabase.deleteDay(day, configuration.logIn);
      day = await getDayFromAPI(configuration, dateTime, time: time);
    }
    print("lessons: ${day.rawLessons.length}");
    return day;
  }

  Future<Day> getDayFromAPI(Configuration configuration, DateTime dateTime,
      {String time = "8:00"}) async {
    String date = convertDateTimeToMMJJAAAAString(dateTime);
    final res = await http.get(
        url + "${configuration.logIn}" + "&date=$date" + "%20$time",
        headers: <String, String>{
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods':
              'GET, POST, OPTIONS, PUT, PATCH, DELETE',
          'Access-Control-Allow-Headers':
              'Access-Control-Allow-Origin, Access-Control-Allow-Methods, Access-Control-Request-Method, Access-Control-Request-Headers, Access-Control-Allow-Headers,Origin, X-Requested-With, Content-Type, Accept, Authorization'
        });

    List<Lesson> lessons = [];
    var document = parse(res.body);
    document.querySelectorAll(".Ligne").forEach((element) {
      lessons.add(Lesson(
        element.querySelector(".Debut").innerHtml,
        element.querySelector(".Fin").innerHtml,
        element.querySelector(".Salle").innerHtml,
        element.querySelector(".Matiere").innerHtml.replaceAll("&amp;", "&"),
        element.querySelector(".Prof").innerHtml,
      ));
    });
    await configuration.localMoorDatabase.addDay(Day(
        date: convertDateTimeToDateTimeWithYearMonthDayOnly(dateTime),
        rawLessons: lessons), configuration.logIn);
    return Day(
        date: convertDateTimeToDateTimeWithYearMonthDayOnly(dateTime),
        rawLessons: lessons);
  }

  String convertDateTimeToMMJJAAAAString(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }
}
