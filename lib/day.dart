import 'package:html/parser.dart';

class Day {
  Day(this.data);

  final String data;
  List<Lesson> lessons = [];

  void init() {
    var document = parse(data);
    document.querySelectorAll(".Ligne").forEach((element) {
      lessons.add(Lesson(
        element.querySelector(".Debut").innerHtml,
        element.querySelector(".Fin").innerHtml,
        element.querySelector(".Salle").innerHtml,
        element.querySelector(".Matiere").innerHtml,
        element.querySelector(".Prof").innerHtml,
      ));
    });
    lessons.forEach((element) {
      element.convertHourToCoordinates();
    });
    for (var i = 0; i < lessons.length; i++){
      //concatain lessons similar
      print(lessons[i].room);
    }
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
    double _min = min / 60 * 100;
    start = hour + _min;

    hour = int.parse(endTime.substring(0, 2));
    min = int.parse(endTime.substring(3, 5));
    _min = min / 60 * 100;
    end = hour + _min;
  }
}




