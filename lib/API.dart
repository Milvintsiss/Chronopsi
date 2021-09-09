import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as p;
import 'package:chronopsi/local_database.dart';

import 'library/calendarDay.dart';
import 'library/day.dart';
import 'library/configuration.dart';

const String urlWigor = 'https://edtmobiliteng.wigorservices.net/WebPsDyn.aspx';
const String urlBeecome =
    'https://edtmobiliteng.wigorservices.net/WebPsDyn.aspx';

class WigorAPI {
  static Dio dio = Dio(BaseOptions(baseUrl: urlWigor));

  static Future<bool> isLogInValid(String logIn) async {
    bool isLogInValid = true;
    String date = convertDateTimeToMMJJAAAAString(DateTime.now());

    var res = await dio.get('', queryParameters: {
      'Action': 'posETUD',
      'serverid': 'h',
      'tel': logIn,
      'date': date,
    });
    print(res.requestOptions.uri);

    Document document = p.parse(res.data);
    if (document.getElementById('Msg') != null &&
        document.getElementById('Msg').innerHtml ==
            "Identifiant erroné, attention l'acces par numéro de mobile est désactivé")
      isLogInValid = false;

    return isLogInValid;
  }

  static Future<Day> getDayFromAPI(
      Configuration configuration, DateTime dateTime) async {
    String date = convertDateTimeToMMJJAAAAString(dateTime);

    var res = await dio.get('', queryParameters: {
      'Action': 'posETUD',
      'serverid': 'h',
      'tel': configuration.logIn,
      'date': date,
    });
    print(res.requestOptions.uri);

    List<Lesson> lessons = [];
    var document = p.parse(res.data);
    document.querySelectorAll(".Ligne").forEach((element) {
      lessons.add(Lesson(
        element.querySelector(".Debut").innerHtml,
        element.querySelector(".Fin").innerHtml,
        element.querySelector(".Salle").innerHtml,
        element.querySelector(".Matiere").innerHtml.replaceAll("&amp;", "&"),
        element.querySelector(".Prof").innerHtml,
      ));
    });
    await configuration.localMoorDatabase.addDay(
        Day(
            date: convertDateTimeToDateTimeWithYearMonthDayOnly(dateTime),
            rawLessons: lessons),
        configuration.logIn);
    return Day(
        date: convertDateTimeToDateTimeWithYearMonthDayOnly(dateTime),
        rawLessons: lessons);
  }

  ///This method didn't return any room for lessons for the moment, should not be used
  Future<List<Day>> getWeekFromAPI(
      Configuration configuration, DateTime dateTime) async {
    dateTime = convertDateTimeToDateTimeWithYearMonthDayOnly(dateTime);
    String date = convertDateTimeToMMJJAAAAString(dateTime);

    var res = await dio.get('', queryParameters: {
      'Action': 'posETUDSEM',
      'serverid': 'h',
      'tel': logIn,
      'date': date,
    });
    print(res.requestOptions.uri);

    var document = p.parse(res.data);
    List<Lesson> lessons = [];
    List<int> lessonsDayIndex = [];
    document.querySelectorAll('.Case').forEach((element) {
      lessons.add(Lesson(
          (element.querySelector('.TChdeb').innerHtml).split(' - ')[0],
          (element.querySelector('.TChdeb').innerHtml).split(' - ')[1],
          element
              .querySelector('.TCSalle')
              .innerHtml
              .replaceFirst('Salle:', ''),
          element
              .querySelector('.TCase')
              .querySelector('.TCase')
              .innerHtml
              .replaceAll("&amp;", "&"),
          addCapsToName(
              element.querySelector('.TCProf').innerHtml.split('<br>')[1])));
      print((element.outerHtml.split('left:')[1]).split(';')[0]);
      switch ((element.outerHtml.split('left:')[1]).split(';')[0]) {
        case '2.000000000000000000000000%':
          lessonsDayIndex.add(0);
          break;
        case '21.600000000000000000000000%':
          lessonsDayIndex.add(1);
          break;
        case '41.200000000000000000000000%':
          lessonsDayIndex.add(2);
          break;
        case '60.800000000000000000000000%':
          lessonsDayIndex.add(3);
          break;
        case '80.400000000000000000000000%':
          lessonsDayIndex.add(4);
          break;
      }
    });
    List<Day> days = [];
    DateTime firstDayOfWeek =
        dateTime.subtract(Duration(days: dateTime.weekday - 1));
    for (int i = 0; i < 7; i++) {
      days.add(
          Day(date: firstDayOfWeek.add(Duration(days: i)), rawLessons: []));
    }

    lessons.forEach((lesson) {
      days[lessonsDayIndex[lessons.indexOf(lesson)]].rawLessons.add(lesson);
    });

    days.forEach((day) async =>
        await configuration.localMoorDatabase.addDay(day, configuration.logIn));
    return days;
  }
}

class BeecomeAPI {
  static Dio dio = Dio(BaseOptions(baseUrl: urlBeecome));

  static Future<Day> getDayFromBeecome(
      Configuration configuration, DateTime dateTime,
      {String time = "8:00"}) async {
    List<Day> daysOfWeek = await getWeekFromBeecome(configuration, dateTime);
    if (daysOfWeek == null) return null;
    Day day = daysOfWeek.firstWhere((Day day) => isSameDay(day.date, dateTime));
    return day;
  }

  static Future<List<Day>> getWeekFromBeecome(
      Configuration configuration, DateTime dateTime) async {
    String date = convertDateTimeToMMJJAAAAString(dateTime);

    int nbOfIterations = 0;
    var res;
    Document document;
    while (res == null ||
        res.statusCode == 302 ||
        res.isRedirect ||
        !_validBeecomeResponse(document)) {
      if (nbOfIterations == 3) return null;
      res = await dio.get('', queryParameters: {
        'Action': 'posEDTBEECOME',
        'serverid': 'C',
        'tel': configuration.logIn,
        'date': date,
      });
      print(res.requestOptions.uri);

      document = p.parse(res.data);
      nbOfIterations++;
    }
    saveCalendar(document, configuration);

    List<Lesson> lessons = [];
    List<int> lessonsDayIndex = [];
    bool isTeacher = document.getElementById('DivEntete_Presence') != null;
    document.querySelectorAll('.Case').forEach((element) {
      if (element.id != 'Apres' &&
          element.innerHtml != "Pas de cours cette semaine") {
        lessons.add(Lesson(
          (element.querySelector('.TChdeb').innerHtml).split(' - ')[0],
          (element.querySelector('.TChdeb').innerHtml).split(' - ')[1],
          element
              .querySelector('.TCSalle')
              .innerHtml
              .replaceFirst('Salle:', ''),
          (isTeacher
                  ? element
                      .querySelector('.TCase')
                      .innerHtml
                      .split('</td>')[0]
                      .split('>')
                      .last
                  : element
                      .querySelector('.TCase')
                      .innerHtml
                      .split('</div>')[2]
                      .split('</td>')[0])
              .replaceAll("&amp;", "&"),
          isTeacher
              ? element
                  .querySelector('.TCProf')
                  .innerHtml
                  .replaceAll(' 20/21 EPSI NTE', '')
                  .replaceAll(' INI', '')
                  .replaceAll(' ALT', '')
              : element
                          .querySelector('.TCProf')
                          .innerHtml
                          .split('<br>')[0]
                          .length >
                      1
                  ? addCapsToName(element
                      .querySelector('.TCProf')
                      .innerHtml
                      .split('<br>')[0])
                  : '',
          wasAbsent: isTeacher
              ? false
              : element.querySelector('.Presence').innerHtml !=
                      '<img src="/img/valide.png">' &&
                  element.querySelector('.Presence').innerHtml != '',
        ));
        switch ((element.outerHtml.split('left:')[1]).split(';')[0]) {
          case '103.1200%':
            lessonsDayIndex.add(0);
            break;
          case '122.5200%':
            lessonsDayIndex.add(1);
            break;
          case '141.9200%':
            lessonsDayIndex.add(2);
            break;
          case '161.3200%':
            lessonsDayIndex.add(3);
            break;
          case '180.7200%':
            lessonsDayIndex.add(4);
            break;
        }
      }
    });
    List<Day> days = [];
    DateTime firstDayOfWeek =
        dateTime.subtract(Duration(days: dateTime.weekday - 1));
    for (int i = 0; i < 7; i++) {
      days.add(
          Day(date: firstDayOfWeek.add(Duration(days: i)), rawLessons: []));
    }

    lessons.forEach((lesson) {
      days[lessonsDayIndex[lessons.indexOf(lesson)]].rawLessons.add(lesson);
    });

    configuration.localMoorDatabase.addDays(days, configuration.logIn);
    return days;
  }

  static Future<List<CalendarDay>> getCalendarFromBeecome(
      Configuration configuration, DateTime dateTime) async {
    dateTime = convertDateTimeToDateTimeWithYearMonthDayOnly(dateTime);
    String date = convertDateTimeToMMJJAAAAString(dateTime);

    var res = await dio.get('', queryParameters: {
      'Action': 'posEDTBEECOME',
      'serverid': 'C',
      'tel': configuration.logIn,
      'date': date,
    });
    print(res.requestOptions.uri);

    Document document = p.parse(res.data);
    if (res.statusCode == 302 || !_validBeecomeResponse(document)) {
      return null;
    } else
      return saveCalendar(document, configuration);
  }

  static bool _validBeecomeResponse(Document document) {
    bool isValid = false;
    document.querySelectorAll('.I_Du_CaseCal').forEach((element) {
      if (element.innerHtml.contains('<img class="I_Du_PresLogo" style="display:block" src="/img/valide.png">') ||
          element.innerHtml.contains(
              '<img class="I_Du_PresLogo" style="display:block" src="/img/crit_16.gif">') ||
          element.outerHtml
              .contains('background-color:#cccccc;font-weight:bolder;'))
        isValid = true;
    });
    return isValid;
  }

  static List<CalendarDay> saveCalendar(
      Document document, Configuration configuration) {
    List<CalendarDay> calendarDays = [];
    DayState dayState;
    document.querySelectorAll('.I_Du_CaseCal').forEach((element) {
      if (element.innerHtml.contains(
          '<img class="I_Du_PresLogo" style="display:block" src="/img/valide.png">'))
        dayState = DayState.present;
      else if (element.innerHtml.contains(
          '<img class="I_Du_PresLogo" style="display:block" src="/img/crit_16.gif">'))
        dayState = DayState.absent;
      else if (element.outerHtml
          .contains('background-color:#cccccc;font-weight:bolder;'))
        dayState = DayState.others;
      else
        dayState = DayState.holiday;

      calendarDays.add(CalendarDay(
        idOfCalendarDayToDateTime(element.id),
        dayState,
      ));
    });

    configuration.localMoorDatabase
        .addCalendarDays(calendarDays, configuration.logIn);
    return calendarDays;
  }
}

String convertDateTimeToMMJJAAAAString(DateTime date) {
  return "${date.month}/${date.day}/${date.year}";
}

String addCapsToName(String name) {
  List<String> _name = name.split(' ');
  name = '';
  _name.forEach((element) {
    name += '${element.replaceRange(0, 1, element[0].toUpperCase())} ';
  });
  return name;
}

DateTime idOfCalendarDayToDateTime(String id) {
  return DateTime(int.parse(id.substring(13, 17)),
      int.parse(id.substring(7, 9)), int.parse(id.substring(10, 12)));
}
