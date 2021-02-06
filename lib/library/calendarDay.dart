enum DayState {
  present,
  absent,
  holiday,
  others
}

class CalendarDay{
  CalendarDay(this.date, this.dayState, {this.savingDate});

  DateTime date;
  DayState dayState;
  DateTime savingDate;
}