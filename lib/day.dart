import 'package:html/parser.dart';

class Day {
  Day(this.data);

  final String data;
  List<Lesson> lessons = [];

  void init(bool concatenateSimilarLessons) {
    var document = parse(data);
    document.querySelectorAll(".Ligne").forEach((element) {
      lessons.add(Lesson(
        element.querySelector(".Debut").innerHtml,
        element.querySelector(".Fin").innerHtml,
        element.querySelector(".Salle").innerHtml,
        element.querySelector(".Matiere").innerHtml.replaceAll("&amp;", "&"),
        element.querySelector(".Prof").innerHtml,
      ));
    });

    if (concatenateSimilarLessons) {
      for (var i = 0; i < lessons.length - 1; i++) {
        if (lessons[i].subject == lessons[i + 1].subject) {
          lessons[i].endTime = lessons[i + 1].endTime;
          lessons.removeAt(i + 1);
        }
      }
    }

    lessons.forEach((element) {
      element.convertHourToCoordinates();
    });
  }
}

class Lesson {
  Lesson(this.startTime, this.endTime, this.room, this.subject, this.professor);

  String startTime;
  String endTime;
  double start;
  double end;
  String room;
  String subject;
  String professor;

  void convertHourToCoordinates(){
    int hour = int.parse(startTime.substring(0, 2));
    int min = int.parse(startTime.substring(3, 5));
    double _min = min / 60;
    start = hour + _min;

    hour = int.parse(endTime.substring(0, 2));
    min = int.parse(endTime.substring(3, 5));
    _min = min / 60;
    end = hour + _min;
  }
}




