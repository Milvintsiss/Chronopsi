import 'package:flutter/cupertino.dart';

class Grade {
  Grade(
      {@required this.label,
      @required this.value,
      @required this.rank,
      @required this.link,
      this.lessonLabel,
      this.category,
      this.id,
      this.teacher});

  String label;
  String lessonLabel;
  String value;
  String rank;
  String category;
  int id;
  String teacher;
  String link;

  void init() {
    int indexFirstNumber;
    int indexLastNumber;
    int indexFirstLetterAfterId;
    List<String> parsedLessonLabel;
    for (int i = 0; i < 10; i++) {
      if (int.tryParse(label[i]) != null) {
        if (indexFirstNumber == null)
          indexFirstNumber = i;
        else {
          if (i - indexFirstNumber == 2) {
            indexLastNumber = i + 1;
          } else if (i - indexFirstNumber != 1) {
            indexFirstNumber = i;
          }
        }
      }
    }
    if (indexLastNumber != null) {
      for (int i = indexLastNumber; indexFirstLetterAfterId == null; i++) {
        if (label[i] != ' ' && label[i] != '_' && label[i] != '-')
          indexFirstLetterAfterId = i;
      }
      id = int.parse(label.substring(indexFirstNumber, indexLastNumber));
      category = label.substring(0, 4);
      lessonLabel = label.substring(indexFirstLetterAfterId);

      parsedLessonLabel = lessonLabel.split(' - ');
      if (parsedLessonLabel.length > 1) {
        teacher = parsedLessonLabel.last;
        lessonLabel = lessonLabel.replaceAll(' - $teacher', '');
      }
    } else {
      lessonLabel = label;
    }
    lessonLabel = lessonLabel.replaceAll('&amp;', '&');
    value = value == '-' ? null : value;
    print(toString());
  }

  @override
  String toString() {
    return 'Grade{label: $label, lessonLabel: $lessonLabel, value: $value, rank: $rank, category: $category, id: $id, teacher: $teacher, link: $link}';
  }
}

class GradesByTeacher {
  List<Grade> grades;
  String teacher;

  GradesByTeacher(this.grades, this.teacher);
}

List<GradesByTeacher> sortGradesByTeacher(List<Grade> grades) {
  List<GradesByTeacher> gradesByTeacher = [];
  List<Grade> gradesWhithoutTeacher = [];
  grades.forEach((grade) {
    if (grade.teacher != null) {
      if (gradesByTeacher
              .indexWhere((element) => element.teacher == grade.teacher) !=
          -1) {
        gradesByTeacher
            .firstWhere((element) => element.teacher == grade.teacher)
            .grades
            .add(grade);
      } else {
        gradesByTeacher.add(GradesByTeacher([grade], grade.teacher));
      }
    } else {
      gradesWhithoutTeacher.add(grade);
    }
  });
  gradesByTeacher.add(GradesByTeacher(gradesWhithoutTeacher, 'Autres'));
  return gradesByTeacher;
}

class GradesByCategory {
  List<Grade> grades;
  String category;

  GradesByCategory(this.grades, this.category);
}

// List<Grade> sortGradesByTeacher(List<Grade> grades) {
//   return grades..sort((a, b) => a.teacher == b.teacher ? 1 : -1);
// }
