import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chronopsi/library/configuration.dart';

import 'day.dart';

const emailEPSI = 'administratif@nantes-epsi.fr';

const List<String> daysWeek = [
  'Lundi',
  'Mardi',
  'Mecredi',
  'Jeudi',
  'Vendredi',
  'Samedi',
  'Dimanche'
];

const List<String> months = [
  "Janvier",
  "Février",
  "Mars",
  "Avril",
  "Mai",
  "Juin",
  "Juillet",
  "Août",
  "Septembre",
  "Octobre",
  "Novembre",
  "Décembre"
];

void justifyAbsence(BuildContext context, Configuration configuration,
    Lesson lesson, DateTime date) {
  String student = configuration.logIn.split('.')[1].replaceRange(
          0, 1, configuration.logIn.split('.')[1][0].toUpperCase()) +
      " " +
      configuration.logIn.split('.')[0].replaceRange(
          0, 1, configuration.logIn.split('.')[0][0].toUpperCase());
  String body = 'Madame, Monsieur,%0A'
      'Je vous prie de bien vouloir excuser mon absence lors du cours de ${lesson.startTime} à ${lesson.endTime} le ${daysWeek[date.weekday]} ${date.day} ${months[date.month - 1]}.%0A'
      'En effet, je n\'ai pas pu être présent lors de ce cours car [raison].%0A'
      'Je vous saurais gré d’en prendre note et m’en remets à votre compréhension.%0A'
      '%0A'
      'Je vous prie de croire, Madame, Monsieur, à l’assurance de mes salutations les plus sincères.';
  launch(
      'mailto:$emailEPSI?subject=Absence $student&body=$body');
}
