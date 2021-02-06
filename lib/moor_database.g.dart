// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moor_database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Lesson extends DataClass implements Insertable<Lesson> {
  final int day;
  final int savingDate;
  final String logIn;
  final String startTime;
  final String endTime;
  final String room;
  final String subject;
  final String professor;
  final bool wasAbsent;
  Lesson(
      {@required this.day,
      @required this.savingDate,
      @required this.logIn,
      this.startTime,
      this.endTime,
      this.room,
      this.subject,
      this.professor,
      this.wasAbsent});
  factory Lesson.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    final boolType = db.typeSystem.forDartType<bool>();
    return Lesson(
      day: intType.mapFromDatabaseResponse(data['${effectivePrefix}day']),
      savingDate: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}saving_date']),
      logIn:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}log_in']),
      startTime: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}start_time']),
      endTime: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}end_time']),
      room: stringType.mapFromDatabaseResponse(data['${effectivePrefix}room']),
      subject:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}subject']),
      professor: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}professor']),
      wasAbsent: boolType
          .mapFromDatabaseResponse(data['${effectivePrefix}was_absent']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || day != null) {
      map['day'] = Variable<int>(day);
    }
    if (!nullToAbsent || savingDate != null) {
      map['saving_date'] = Variable<int>(savingDate);
    }
    if (!nullToAbsent || logIn != null) {
      map['log_in'] = Variable<String>(logIn);
    }
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<String>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<String>(endTime);
    }
    if (!nullToAbsent || room != null) {
      map['room'] = Variable<String>(room);
    }
    if (!nullToAbsent || subject != null) {
      map['subject'] = Variable<String>(subject);
    }
    if (!nullToAbsent || professor != null) {
      map['professor'] = Variable<String>(professor);
    }
    if (!nullToAbsent || wasAbsent != null) {
      map['was_absent'] = Variable<bool>(wasAbsent);
    }
    return map;
  }

  LessonsCompanion toCompanion(bool nullToAbsent) {
    return LessonsCompanion(
      day: day == null && nullToAbsent ? const Value.absent() : Value(day),
      savingDate: savingDate == null && nullToAbsent
          ? const Value.absent()
          : Value(savingDate),
      logIn:
          logIn == null && nullToAbsent ? const Value.absent() : Value(logIn),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      room: room == null && nullToAbsent ? const Value.absent() : Value(room),
      subject: subject == null && nullToAbsent
          ? const Value.absent()
          : Value(subject),
      professor: professor == null && nullToAbsent
          ? const Value.absent()
          : Value(professor),
      wasAbsent: wasAbsent == null && nullToAbsent
          ? const Value.absent()
          : Value(wasAbsent),
    );
  }

  factory Lesson.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Lesson(
      day: serializer.fromJson<int>(json['day']),
      savingDate: serializer.fromJson<int>(json['savingDate']),
      logIn: serializer.fromJson<String>(json['logIn']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      room: serializer.fromJson<String>(json['room']),
      subject: serializer.fromJson<String>(json['subject']),
      professor: serializer.fromJson<String>(json['professor']),
      wasAbsent: serializer.fromJson<bool>(json['wasAbsent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<int>(day),
      'savingDate': serializer.toJson<int>(savingDate),
      'logIn': serializer.toJson<String>(logIn),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'room': serializer.toJson<String>(room),
      'subject': serializer.toJson<String>(subject),
      'professor': serializer.toJson<String>(professor),
      'wasAbsent': serializer.toJson<bool>(wasAbsent),
    };
  }

  Lesson copyWith(
          {int day,
          int savingDate,
          String logIn,
          String startTime,
          String endTime,
          String room,
          String subject,
          String professor,
          bool wasAbsent}) =>
      Lesson(
        day: day ?? this.day,
        savingDate: savingDate ?? this.savingDate,
        logIn: logIn ?? this.logIn,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        room: room ?? this.room,
        subject: subject ?? this.subject,
        professor: professor ?? this.professor,
        wasAbsent: wasAbsent ?? this.wasAbsent,
      );
  @override
  String toString() {
    return (StringBuffer('Lesson(')
          ..write('day: $day, ')
          ..write('savingDate: $savingDate, ')
          ..write('logIn: $logIn, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('room: $room, ')
          ..write('subject: $subject, ')
          ..write('professor: $professor, ')
          ..write('wasAbsent: $wasAbsent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      day.hashCode,
      $mrjc(
          savingDate.hashCode,
          $mrjc(
              logIn.hashCode,
              $mrjc(
                  startTime.hashCode,
                  $mrjc(
                      endTime.hashCode,
                      $mrjc(
                          room.hashCode,
                          $mrjc(
                              subject.hashCode,
                              $mrjc(professor.hashCode,
                                  wasAbsent.hashCode)))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Lesson &&
          other.day == this.day &&
          other.savingDate == this.savingDate &&
          other.logIn == this.logIn &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.room == this.room &&
          other.subject == this.subject &&
          other.professor == this.professor &&
          other.wasAbsent == this.wasAbsent);
}

class LessonsCompanion extends UpdateCompanion<Lesson> {
  final Value<int> day;
  final Value<int> savingDate;
  final Value<String> logIn;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<String> room;
  final Value<String> subject;
  final Value<String> professor;
  final Value<bool> wasAbsent;
  const LessonsCompanion({
    this.day = const Value.absent(),
    this.savingDate = const Value.absent(),
    this.logIn = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.room = const Value.absent(),
    this.subject = const Value.absent(),
    this.professor = const Value.absent(),
    this.wasAbsent = const Value.absent(),
  });
  LessonsCompanion.insert({
    @required int day,
    @required int savingDate,
    @required String logIn,
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.room = const Value.absent(),
    this.subject = const Value.absent(),
    this.professor = const Value.absent(),
    this.wasAbsent = const Value.absent(),
  })  : day = Value(day),
        savingDate = Value(savingDate),
        logIn = Value(logIn);
  static Insertable<Lesson> custom({
    Expression<int> day,
    Expression<int> savingDate,
    Expression<String> logIn,
    Expression<String> startTime,
    Expression<String> endTime,
    Expression<String> room,
    Expression<String> subject,
    Expression<String> professor,
    Expression<bool> wasAbsent,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (savingDate != null) 'saving_date': savingDate,
      if (logIn != null) 'log_in': logIn,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (room != null) 'room': room,
      if (subject != null) 'subject': subject,
      if (professor != null) 'professor': professor,
      if (wasAbsent != null) 'was_absent': wasAbsent,
    });
  }

  LessonsCompanion copyWith(
      {Value<int> day,
      Value<int> savingDate,
      Value<String> logIn,
      Value<String> startTime,
      Value<String> endTime,
      Value<String> room,
      Value<String> subject,
      Value<String> professor,
      Value<bool> wasAbsent}) {
    return LessonsCompanion(
      day: day ?? this.day,
      savingDate: savingDate ?? this.savingDate,
      logIn: logIn ?? this.logIn,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      subject: subject ?? this.subject,
      professor: professor ?? this.professor,
      wasAbsent: wasAbsent ?? this.wasAbsent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (savingDate.present) {
      map['saving_date'] = Variable<int>(savingDate.value);
    }
    if (logIn.present) {
      map['log_in'] = Variable<String>(logIn.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (professor.present) {
      map['professor'] = Variable<String>(professor.value);
    }
    if (wasAbsent.present) {
      map['was_absent'] = Variable<bool>(wasAbsent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonsCompanion(')
          ..write('day: $day, ')
          ..write('savingDate: $savingDate, ')
          ..write('logIn: $logIn, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('room: $room, ')
          ..write('subject: $subject, ')
          ..write('professor: $professor, ')
          ..write('wasAbsent: $wasAbsent')
          ..write(')'))
        .toString();
  }
}

class $LessonsTable extends Lessons with TableInfo<$LessonsTable, Lesson> {
  final GeneratedDatabase _db;
  final String _alias;
  $LessonsTable(this._db, [this._alias]);
  final VerificationMeta _dayMeta = const VerificationMeta('day');
  GeneratedIntColumn _day;
  @override
  GeneratedIntColumn get day => _day ??= _constructDay();
  GeneratedIntColumn _constructDay() {
    return GeneratedIntColumn(
      'day',
      $tableName,
      false,
    );
  }

  final VerificationMeta _savingDateMeta = const VerificationMeta('savingDate');
  GeneratedIntColumn _savingDate;
  @override
  GeneratedIntColumn get savingDate => _savingDate ??= _constructSavingDate();
  GeneratedIntColumn _constructSavingDate() {
    return GeneratedIntColumn(
      'saving_date',
      $tableName,
      false,
    );
  }

  final VerificationMeta _logInMeta = const VerificationMeta('logIn');
  GeneratedTextColumn _logIn;
  @override
  GeneratedTextColumn get logIn => _logIn ??= _constructLogIn();
  GeneratedTextColumn _constructLogIn() {
    return GeneratedTextColumn(
      'log_in',
      $tableName,
      false,
    );
  }

  final VerificationMeta _startTimeMeta = const VerificationMeta('startTime');
  GeneratedTextColumn _startTime;
  @override
  GeneratedTextColumn get startTime => _startTime ??= _constructStartTime();
  GeneratedTextColumn _constructStartTime() {
    return GeneratedTextColumn(
      'start_time',
      $tableName,
      true,
    );
  }

  final VerificationMeta _endTimeMeta = const VerificationMeta('endTime');
  GeneratedTextColumn _endTime;
  @override
  GeneratedTextColumn get endTime => _endTime ??= _constructEndTime();
  GeneratedTextColumn _constructEndTime() {
    return GeneratedTextColumn(
      'end_time',
      $tableName,
      true,
    );
  }

  final VerificationMeta _roomMeta = const VerificationMeta('room');
  GeneratedTextColumn _room;
  @override
  GeneratedTextColumn get room => _room ??= _constructRoom();
  GeneratedTextColumn _constructRoom() {
    return GeneratedTextColumn(
      'room',
      $tableName,
      true,
    );
  }

  final VerificationMeta _subjectMeta = const VerificationMeta('subject');
  GeneratedTextColumn _subject;
  @override
  GeneratedTextColumn get subject => _subject ??= _constructSubject();
  GeneratedTextColumn _constructSubject() {
    return GeneratedTextColumn(
      'subject',
      $tableName,
      true,
    );
  }

  final VerificationMeta _professorMeta = const VerificationMeta('professor');
  GeneratedTextColumn _professor;
  @override
  GeneratedTextColumn get professor => _professor ??= _constructProfessor();
  GeneratedTextColumn _constructProfessor() {
    return GeneratedTextColumn(
      'professor',
      $tableName,
      true,
    );
  }

  final VerificationMeta _wasAbsentMeta = const VerificationMeta('wasAbsent');
  GeneratedBoolColumn _wasAbsent;
  @override
  GeneratedBoolColumn get wasAbsent => _wasAbsent ??= _constructWasAbsent();
  GeneratedBoolColumn _constructWasAbsent() {
    return GeneratedBoolColumn(
      'was_absent',
      $tableName,
      true,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [
        day,
        savingDate,
        logIn,
        startTime,
        endTime,
        room,
        subject,
        professor,
        wasAbsent
      ];
  @override
  $LessonsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'lessons';
  @override
  final String actualTableName = 'lessons';
  @override
  VerificationContext validateIntegrity(Insertable<Lesson> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day'], _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('saving_date')) {
      context.handle(
          _savingDateMeta,
          savingDate.isAcceptableOrUnknown(
              data['saving_date'], _savingDateMeta));
    } else if (isInserting) {
      context.missing(_savingDateMeta);
    }
    if (data.containsKey('log_in')) {
      context.handle(
          _logInMeta, logIn.isAcceptableOrUnknown(data['log_in'], _logInMeta));
    } else if (isInserting) {
      context.missing(_logInMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time'], _startTimeMeta));
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time'], _endTimeMeta));
    }
    if (data.containsKey('room')) {
      context.handle(
          _roomMeta, room.isAcceptableOrUnknown(data['room'], _roomMeta));
    }
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject'], _subjectMeta));
    }
    if (data.containsKey('professor')) {
      context.handle(_professorMeta,
          professor.isAcceptableOrUnknown(data['professor'], _professorMeta));
    }
    if (data.containsKey('was_absent')) {
      context.handle(_wasAbsentMeta,
          wasAbsent.isAcceptableOrUnknown(data['was_absent'], _wasAbsentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => <GeneratedColumn>{};
  @override
  Lesson map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Lesson.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $LessonsTable createAlias(String alias) {
    return $LessonsTable(_db, alias);
  }
}

class CalendarDay extends DataClass implements Insertable<CalendarDay> {
  final int day;
  final int savingDate;
  final String logIn;
  final String state;
  CalendarDay(
      {@required this.day,
      @required this.savingDate,
      @required this.logIn,
      @required this.state});
  factory CalendarDay.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return CalendarDay(
      day: intType.mapFromDatabaseResponse(data['${effectivePrefix}day']),
      savingDate: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}saving_date']),
      logIn:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}log_in']),
      state:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}state']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || day != null) {
      map['day'] = Variable<int>(day);
    }
    if (!nullToAbsent || savingDate != null) {
      map['saving_date'] = Variable<int>(savingDate);
    }
    if (!nullToAbsent || logIn != null) {
      map['log_in'] = Variable<String>(logIn);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    return map;
  }

  CalendarDaysCompanion toCompanion(bool nullToAbsent) {
    return CalendarDaysCompanion(
      day: day == null && nullToAbsent ? const Value.absent() : Value(day),
      savingDate: savingDate == null && nullToAbsent
          ? const Value.absent()
          : Value(savingDate),
      logIn:
          logIn == null && nullToAbsent ? const Value.absent() : Value(logIn),
      state:
          state == null && nullToAbsent ? const Value.absent() : Value(state),
    );
  }

  factory CalendarDay.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return CalendarDay(
      day: serializer.fromJson<int>(json['day']),
      savingDate: serializer.fromJson<int>(json['savingDate']),
      logIn: serializer.fromJson<String>(json['logIn']),
      state: serializer.fromJson<String>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<int>(day),
      'savingDate': serializer.toJson<int>(savingDate),
      'logIn': serializer.toJson<String>(logIn),
      'state': serializer.toJson<String>(state),
    };
  }

  CalendarDay copyWith({int day, int savingDate, String logIn, String state}) =>
      CalendarDay(
        day: day ?? this.day,
        savingDate: savingDate ?? this.savingDate,
        logIn: logIn ?? this.logIn,
        state: state ?? this.state,
      );
  @override
  String toString() {
    return (StringBuffer('CalendarDay(')
          ..write('day: $day, ')
          ..write('savingDate: $savingDate, ')
          ..write('logIn: $logIn, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(day.hashCode,
      $mrjc(savingDate.hashCode, $mrjc(logIn.hashCode, state.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is CalendarDay &&
          other.day == this.day &&
          other.savingDate == this.savingDate &&
          other.logIn == this.logIn &&
          other.state == this.state);
}

class CalendarDaysCompanion extends UpdateCompanion<CalendarDay> {
  final Value<int> day;
  final Value<int> savingDate;
  final Value<String> logIn;
  final Value<String> state;
  const CalendarDaysCompanion({
    this.day = const Value.absent(),
    this.savingDate = const Value.absent(),
    this.logIn = const Value.absent(),
    this.state = const Value.absent(),
  });
  CalendarDaysCompanion.insert({
    @required int day,
    @required int savingDate,
    @required String logIn,
    @required String state,
  })  : day = Value(day),
        savingDate = Value(savingDate),
        logIn = Value(logIn),
        state = Value(state);
  static Insertable<CalendarDay> custom({
    Expression<int> day,
    Expression<int> savingDate,
    Expression<String> logIn,
    Expression<String> state,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (savingDate != null) 'saving_date': savingDate,
      if (logIn != null) 'log_in': logIn,
      if (state != null) 'state': state,
    });
  }

  CalendarDaysCompanion copyWith(
      {Value<int> day,
      Value<int> savingDate,
      Value<String> logIn,
      Value<String> state}) {
    return CalendarDaysCompanion(
      day: day ?? this.day,
      savingDate: savingDate ?? this.savingDate,
      logIn: logIn ?? this.logIn,
      state: state ?? this.state,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (savingDate.present) {
      map['saving_date'] = Variable<int>(savingDate.value);
    }
    if (logIn.present) {
      map['log_in'] = Variable<String>(logIn.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarDaysCompanion(')
          ..write('day: $day, ')
          ..write('savingDate: $savingDate, ')
          ..write('logIn: $logIn, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }
}

class $CalendarDaysTable extends CalendarDays
    with TableInfo<$CalendarDaysTable, CalendarDay> {
  final GeneratedDatabase _db;
  final String _alias;
  $CalendarDaysTable(this._db, [this._alias]);
  final VerificationMeta _dayMeta = const VerificationMeta('day');
  GeneratedIntColumn _day;
  @override
  GeneratedIntColumn get day => _day ??= _constructDay();
  GeneratedIntColumn _constructDay() {
    return GeneratedIntColumn(
      'day',
      $tableName,
      false,
    );
  }

  final VerificationMeta _savingDateMeta = const VerificationMeta('savingDate');
  GeneratedIntColumn _savingDate;
  @override
  GeneratedIntColumn get savingDate => _savingDate ??= _constructSavingDate();
  GeneratedIntColumn _constructSavingDate() {
    return GeneratedIntColumn(
      'saving_date',
      $tableName,
      false,
    );
  }

  final VerificationMeta _logInMeta = const VerificationMeta('logIn');
  GeneratedTextColumn _logIn;
  @override
  GeneratedTextColumn get logIn => _logIn ??= _constructLogIn();
  GeneratedTextColumn _constructLogIn() {
    return GeneratedTextColumn(
      'log_in',
      $tableName,
      false,
    );
  }

  final VerificationMeta _stateMeta = const VerificationMeta('state');
  GeneratedTextColumn _state;
  @override
  GeneratedTextColumn get state => _state ??= _constructState();
  GeneratedTextColumn _constructState() {
    return GeneratedTextColumn(
      'state',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [day, savingDate, logIn, state];
  @override
  $CalendarDaysTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'calendar_days';
  @override
  final String actualTableName = 'calendar_days';
  @override
  VerificationContext validateIntegrity(Insertable<CalendarDay> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day'], _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('saving_date')) {
      context.handle(
          _savingDateMeta,
          savingDate.isAcceptableOrUnknown(
              data['saving_date'], _savingDateMeta));
    } else if (isInserting) {
      context.missing(_savingDateMeta);
    }
    if (data.containsKey('log_in')) {
      context.handle(
          _logInMeta, logIn.isAcceptableOrUnknown(data['log_in'], _logInMeta));
    } else if (isInserting) {
      context.missing(_logInMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state'], _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => <GeneratedColumn>{};
  @override
  CalendarDay map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return CalendarDay.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $CalendarDaysTable createAlias(String alias) {
    return $CalendarDaysTable(_db, alias);
  }
}

abstract class _$AppMoorDatabase extends GeneratedDatabase {
  _$AppMoorDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $LessonsTable _lessons;
  $LessonsTable get lessons => _lessons ??= $LessonsTable(this);
  $CalendarDaysTable _calendarDays;
  $CalendarDaysTable get calendarDays =>
      _calendarDays ??= $CalendarDaysTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [lessons, calendarDays];
}
