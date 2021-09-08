import 'package:html/dom.dart';
import 'package:html/parser.dart' as p;
import 'package:http/http.dart' as http;
import 'package:chronopsi/local_database.dart';

import 'library/calendarDay.dart';
import 'library/day.dart';
import 'library/configuration.dart';

const String wigorDomain = 'edtmobiliteng.wigorservices.net';

const String wigorPath = '/WebPsDyn.aspx';

Future<bool> isLogInValid(String logIn) async {
  bool isLogInValid = true;
  String date = convertDateTimeToMMJJAAAAString(DateTime.now());

  final Uri uri = Uri.https(wigorDomain, wigorPath, {
    'Action': 'posETUD',
    'serverid': 'h',
    'tel': logIn,
    'date': date,
  });
  print(uri);
  final res = await http.get(uri);

  Document document = p.parse(res.body);
  if (document.getElementById('Msg') != null &&
      document.getElementById('Msg').innerHtml ==
          "Identifiant erroné, attention l'acces par numéro de mobile est désactivé")
    isLogInValid = false;

  return isLogInValid;
}

Future<Day> getDayFromAPI(
    Configuration configuration, DateTime dateTime) async {
  String date = convertDateTimeToMMJJAAAAString(dateTime);

  final Uri uri = Uri.https(wigorDomain, wigorPath, {
    'Action': 'posETUD',
    'serverid': 'h',
    'tel': configuration.logIn,
    'date': date,
  });
  print(uri);
  final res = await http.get(uri);

  List<Lesson> lessons = [];
  var document = p.parse(res.body);
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

  final Uri uri = Uri.https(wigorDomain, wigorPath, {
    'Action': 'posETUDSEM',
    'serverid': 'h',
    'tel': configuration.logIn,
    'date': date,
  });
  print(uri);
  final res = await http.get(uri);

  var document = p.parse(res.body);
  List<Lesson> lessons = [];
  List<int> lessonsDayIndex = [];
  document.querySelectorAll('.Case').forEach((element) {
    lessons.add(Lesson(
        (element.querySelector('.TChdeb').innerHtml).split(' - ')[0],
        (element.querySelector('.TChdeb').innerHtml).split(' - ')[1],
        element.querySelector('.TCSalle').innerHtml.replaceFirst('Salle:', ''),
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
    days.add(Day(date: firstDayOfWeek.add(Duration(days: i)), rawLessons: []));
  }

  lessons.forEach((lesson) {
    days[lessonsDayIndex[lessons.indexOf(lesson)]].rawLessons.add(lesson);
  });

  days.forEach((day) async =>
      await configuration.localMoorDatabase.addDay(day, configuration.logIn));
  return days;
}

Future<Day> getDayFromBeecome(Configuration configuration, DateTime dateTime,
    {String time = "8:00"}) async {
  List<Day> daysOfWeek = await getWeekFromBeecome(configuration, dateTime);
  Day day = daysOfWeek.firstWhere((Day day) => isSameDay(day.date, dateTime));
  return day;
}

Future<List<Day>> getWeekFromBeecome(
    Configuration configuration, DateTime dateTime) async {
  String date = convertDateTimeToMMJJAAAAString(dateTime);

  var res;
  Document document;
  while (res == null ||
      res.statusCode == 302 ||
      res.isRedirect ||
      saveCalendar(document, configuration).length == 0) {
    final Uri uri = Uri.https(wigorDomain, wigorPath, {
      'Action': 'posEDTBEECOME',
      'serverid': 'C',
      'tel': configuration.logIn,
      'date': date,
    });
    print(uri);
    res = await http.get(uri);

    document = p.parse(res.body);
  }

  List<Lesson> lessons = [];
  List<int> lessonsDayIndex = [];
  bool isTeacher = document.getElementById('DivEntete_Presence') != null;
  document.querySelectorAll('.Case').forEach((element) {
    if (element.id != 'Apres' &&
        element.innerHtml != "Pas de cours cette semaine") {
      lessons.add(Lesson(
        (element.querySelector('.TChdeb').innerHtml).split(' - ')[0],
        (element.querySelector('.TChdeb').innerHtml).split(' - ')[1],
        element.querySelector('.TCSalle').innerHtml.replaceFirst('Salle:', ''),
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
                ? addCapsToName(
                    element.querySelector('.TCProf').innerHtml.split('<br>')[0])
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
    days.add(Day(date: firstDayOfWeek.add(Duration(days: i)), rawLessons: []));
  }

  lessons.forEach((lesson) {
    days[lessonsDayIndex[lessons.indexOf(lesson)]].rawLessons.add(lesson);
  });

  configuration.localMoorDatabase.addDays(days, configuration.logIn);
  return days;
}

Future<List<CalendarDay>> getCalendarFromBeecome(
    Configuration configuration, DateTime dateTime) async {
  dateTime = convertDateTimeToDateTimeWithYearMonthDayOnly(dateTime);
  String date = convertDateTimeToMMJJAAAAString(dateTime);

  final Uri uri = Uri.https(wigorDomain, wigorPath, {
    'Action': 'posEDTBEECOME',
    'serverid': 'C',
    'tel': configuration.logIn,
    'date': date,
  });
  print(uri);
  final res = await http.get(uri);

  Document document = p.parse(res.body);
  if (res.statusCode == 302) {
    //prevent beecome bugs
    getCalendarFromBeecome(configuration, dateTime);
    return null;
  } else
    return saveCalendar(document, configuration);
}

List<CalendarDay> saveCalendar(Document document, Configuration configuration) {
  bool requestValid = false;
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

    if (dayState == DayState.present ||
        dayState == DayState.present ||
        dayState == DayState.others) requestValid = true;
  });

  if (requestValid) {
    configuration.localMoorDatabase
        .addCalendarDays(calendarDays, configuration.logIn);
    return calendarDays;
  } else
    return <CalendarDay>[];
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
