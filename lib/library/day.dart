import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Day {
  Day({@required this.date, @required this.rawLessons});

  List<Lesson> rawLessons;
  List<Lesson> lessons = [];
  DateTime date;
  bool isEmpty;

  void init(bool concatenateSimilarLessons) {
    if (rawLessons.length > 0 && rawLessons[0].startTime != null) {
      isEmpty = false;
      lessons = rawLessons;
      if (concatenateSimilarLessons) {
        for (var i = 0; i < lessons.length - 1; i++) {
          if (lessons[i].subject == lessons[i + 1].subject &&
              lessons[i].endTime == lessons[i + 1].startTime &&
              lessons[i].room == lessons[i + 1].room &&
              lessons[i].wasAbsent == lessons[i + 1].wasAbsent) {
            lessons[i].endTime = lessons[i + 1].endTime;
            lessons.removeAt(i + 1);
          }
        }
      }
      lessons.forEach((element) {
        element.convertHourToCoordinates();
        element.convertHourToHourInt();
      });
    } else {
      isEmpty = true;
    }
  }
}

DateTime convertDateTimeToDateTimeWithYearMonthDayOnly(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

class Lesson {
  Lesson(this.startTime, this.endTime, this.room, this.subject, this.professor,
      {this.wasAbsent = false, this.savingDate});

  String startTime;
  String endTime;
  double start;
  double end;
  int startHour;
  int startMin;
  int endHour;
  int endMin;
  String room;
  String subject;
  String professor;
  bool wasAbsent;
  DateTime savingDate;

  LessonState lessonState;
  int daysRemeaning = 0;
  int hoursRemeaning = 0;
  int minRemeaning = 0;

  void convertHourToCoordinates() {
    int hour = int.parse(startTime.substring(0, 2));
    int min = int.parse(startTime.substring(3, 5));
    double _min = min / 60;
    start = hour + _min;

    hour = int.parse(endTime.substring(0, 2));
    min = int.parse(endTime.substring(3, 5));
    _min = min / 60;
    end = hour + _min;
  }

  void convertHourToHourInt() {
    startHour = int.parse(startTime.substring(0, 2));
    startMin = int.parse(startTime.substring(3, 5));
    endHour = int.parse(endTime.substring(0, 2));
    endMin = int.parse(endTime.substring(3, 5));
  }

  void setState(DateTime selectedDay) {
    DateTime lessonStart = DateTime(selectedDay.year, selectedDay.month,
        selectedDay.day, startHour, startMin);
    DateTime lessonEnd = DateTime(
        selectedDay.year, selectedDay.month, selectedDay.day, endHour, endMin);
    if (lessonStart.isAfter(DateTime.now())) {
      lessonState = LessonState.UPCOMING;
      DateTimeRange difference =
          DateTimeRange(start: DateTime.now(), end: lessonStart);
      daysRemeaning = difference.duration.inDays;
      hoursRemeaning = difference.duration.inHours;
      minRemeaning =
          difference.duration.inMinutes - (difference.duration.inHours * 60);
    } else if (lessonEnd.isAfter(DateTime.now()))
      lessonState = LessonState.CURRENT;
    else
      lessonState = LessonState.ELAPSED;
  }
}

enum LessonState { CURRENT, UPCOMING, ELAPSED }

Day testDay = Day(date: DateTime(2021, 01, 26), rawLessons: [
  Lesson(
    "08:00",
    "12:50",
    "SALLE_01",
    "Cours C++",
    "Professeur",
  ),
  Lesson(
    "13:00",
    "15:00",
    "SALLE_01",
    "Cours C++",
    "Professeur",
  ),
]);
