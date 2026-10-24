// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MusclesTable extends Muscles with TableInfo<$MusclesTable, Muscle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MusclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'muscles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Muscle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Muscle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Muscle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $MusclesTable createAlias(String alias) {
    return $MusclesTable(attachedDatabase, alias);
  }
}

class Muscle extends DataClass implements Insertable<Muscle> {
  final int id;
  final String name;
  const Muscle({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  MusclesCompanion toCompanion(bool nullToAbsent) {
    return MusclesCompanion(id: Value(id), name: Value(name));
  }

  factory Muscle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Muscle(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Muscle copyWith({int? id, String? name}) =>
      Muscle(id: id ?? this.id, name: name ?? this.name);
  Muscle copyWithCompanion(MusclesCompanion data) {
    return Muscle(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Muscle(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Muscle && other.id == this.id && other.name == this.name);
}

class MusclesCompanion extends UpdateCompanion<Muscle> {
  final Value<int> id;
  final Value<String> name;
  const MusclesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  MusclesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Muscle> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  MusclesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return MusclesCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MusclesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, equipment, isCustom];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    } else if (isInserting) {
      context.missing(_equipmentMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      )!,
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final int id;
  final String name;
  final String equipment;
  final bool isCustom;
  const Exercise({
    required this.id,
    required this.name,
    required this.equipment,
    required this.isCustom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['equipment'] = Variable<String>(equipment);
    map['is_custom'] = Variable<bool>(isCustom);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      equipment: Value(equipment),
      isCustom: Value(isCustom),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      equipment: serializer.fromJson<String>(json['equipment']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'equipment': serializer.toJson<String>(equipment),
      'isCustom': serializer.toJson<bool>(isCustom),
    };
  }

  Exercise copyWith({
    int? id,
    String? name,
    String? equipment,
    bool? isCustom,
  }) => Exercise(
    id: id ?? this.id,
    name: name ?? this.name,
    equipment: equipment ?? this.equipment,
    isCustom: isCustom ?? this.isCustom,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('equipment: $equipment, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, equipment, isCustom);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.equipment == this.equipment &&
          other.isCustom == this.isCustom);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> equipment;
  final Value<bool> isCustom;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.equipment = const Value.absent(),
    this.isCustom = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String equipment,
    this.isCustom = const Value.absent(),
  }) : name = Value(name),
       equipment = Value(equipment);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? equipment,
    Expression<bool>? isCustom,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (equipment != null) 'equipment': equipment,
      if (isCustom != null) 'is_custom': isCustom,
    });
  }

  ExercisesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? equipment,
    Value<bool>? isCustom,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      equipment: equipment ?? this.equipment,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('equipment: $equipment, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }
}

class $ExerciseMusclesTable extends ExerciseMuscles
    with TableInfo<$ExerciseMusclesTable, ExerciseMuscle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseMusclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _muscleIdMeta = const VerificationMeta(
    'muscleId',
  );
  @override
  late final GeneratedColumn<int> muscleId = GeneratedColumn<int>(
    'muscle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES muscles (id)',
    ),
  );
  static const VerificationMeta _shareMeta = const VerificationMeta('share');
  @override
  late final GeneratedColumn<double> share = GeneratedColumn<double>(
    'share',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [exerciseId, muscleId, share];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_muscles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseMuscle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('muscle_id')) {
      context.handle(
        _muscleIdMeta,
        muscleId.isAcceptableOrUnknown(data['muscle_id']!, _muscleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_muscleIdMeta);
    }
    if (data.containsKey('share')) {
      context.handle(
        _shareMeta,
        share.isAcceptableOrUnknown(data['share']!, _shareMeta),
      );
    } else if (isInserting) {
      context.missing(_shareMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId, muscleId};
  @override
  ExerciseMuscle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseMuscle(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      muscleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}muscle_id'],
      )!,
      share: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}share'],
      )!,
    );
  }

  @override
  $ExerciseMusclesTable createAlias(String alias) {
    return $ExerciseMusclesTable(attachedDatabase, alias);
  }
}

class ExerciseMuscle extends DataClass implements Insertable<ExerciseMuscle> {
  final int exerciseId;
  final int muscleId;
  final double share;
  const ExerciseMuscle({
    required this.exerciseId,
    required this.muscleId,
    required this.share,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<int>(exerciseId);
    map['muscle_id'] = Variable<int>(muscleId);
    map['share'] = Variable<double>(share);
    return map;
  }

  ExerciseMusclesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseMusclesCompanion(
      exerciseId: Value(exerciseId),
      muscleId: Value(muscleId),
      share: Value(share),
    );
  }

  factory ExerciseMuscle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseMuscle(
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      muscleId: serializer.fromJson<int>(json['muscleId']),
      share: serializer.fromJson<double>(json['share']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<int>(exerciseId),
      'muscleId': serializer.toJson<int>(muscleId),
      'share': serializer.toJson<double>(share),
    };
  }

  ExerciseMuscle copyWith({int? exerciseId, int? muscleId, double? share}) =>
      ExerciseMuscle(
        exerciseId: exerciseId ?? this.exerciseId,
        muscleId: muscleId ?? this.muscleId,
        share: share ?? this.share,
      );
  ExerciseMuscle copyWithCompanion(ExerciseMusclesCompanion data) {
    return ExerciseMuscle(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      muscleId: data.muscleId.present ? data.muscleId.value : this.muscleId,
      share: data.share.present ? data.share.value : this.share,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMuscle(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscleId: $muscleId, ')
          ..write('share: $share')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, muscleId, share);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseMuscle &&
          other.exerciseId == this.exerciseId &&
          other.muscleId == this.muscleId &&
          other.share == this.share);
}

class ExerciseMusclesCompanion extends UpdateCompanion<ExerciseMuscle> {
  final Value<int> exerciseId;
  final Value<int> muscleId;
  final Value<double> share;
  final Value<int> rowid;
  const ExerciseMusclesCompanion({
    this.exerciseId = const Value.absent(),
    this.muscleId = const Value.absent(),
    this.share = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseMusclesCompanion.insert({
    required int exerciseId,
    required int muscleId,
    required double share,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       muscleId = Value(muscleId),
       share = Value(share);
  static Insertable<ExerciseMuscle> custom({
    Expression<int>? exerciseId,
    Expression<int>? muscleId,
    Expression<double>? share,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (muscleId != null) 'muscle_id': muscleId,
      if (share != null) 'share': share,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseMusclesCompanion copyWith({
    Value<int>? exerciseId,
    Value<int>? muscleId,
    Value<double>? share,
    Value<int>? rowid,
  }) {
    return ExerciseMusclesCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      muscleId: muscleId ?? this.muscleId,
      share: share ?? this.share,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (muscleId.present) {
      map['muscle_id'] = Variable<int>(muscleId.value);
    }
    if (share.present) {
      map['share'] = Variable<double>(share.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMusclesCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscleId: $muscleId, ')
          ..write('share: $share, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutsTable extends Workouts with TableInfo<$WorkoutsTable, Workout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, startedAt, finishedAt, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Workout> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workout(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }
}

class Workout extends DataClass implements Insertable<Workout> {
  final int id;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final String? note;
  const Workout({
    required this.id,
    required this.startedAt,
    this.finishedAt,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Workout.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workout(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'note': serializer.toJson<String?>(note),
    };
  }

  Workout copyWith({
    int? id,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Workout(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    note: note.present ? note.value : this.note,
  );
  Workout copyWithCompanion(WorkoutsCompanion data) {
    return Workout(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workout(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, startedAt, finishedAt, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workout &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.note == this.note);
}

class WorkoutsCompanion extends UpdateCompanion<Workout> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<String?> note;
  const WorkoutsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.note = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    this.note = const Value.absent(),
  }) : startedAt = Value(startedAt);
  static Insertable<Workout> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (note != null) 'note': note,
    });
  }

  WorkoutsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<String?>? note,
  }) {
    return WorkoutsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $WorkoutExercisesTable extends WorkoutExercises
    with TableInfo<$WorkoutExercisesTable, WorkoutExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
    'workout_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workouts (id)',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, workoutId, exerciseId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workout_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $WorkoutExercisesTable createAlias(String alias) {
    return $WorkoutExercisesTable(attachedDatabase, alias);
  }
}

class WorkoutExercise extends DataClass implements Insertable<WorkoutExercise> {
  final int id;
  final int workoutId;
  final int exerciseId;
  final int position;
  const WorkoutExercise({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workout_id'] = Variable<int>(workoutId);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['position'] = Variable<int>(position);
    return map;
  }

  WorkoutExercisesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutExercisesCompanion(
      id: Value(id),
      workoutId: Value(workoutId),
      exerciseId: Value(exerciseId),
      position: Value(position),
    );
  }

  factory WorkoutExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutExercise(
      id: serializer.fromJson<int>(json['id']),
      workoutId: serializer.fromJson<int>(json['workoutId']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workoutId': serializer.toJson<int>(workoutId),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'position': serializer.toJson<int>(position),
    };
  }

  WorkoutExercise copyWith({
    int? id,
    int? workoutId,
    int? exerciseId,
    int? position,
  }) => WorkoutExercise(
    id: id ?? this.id,
    workoutId: workoutId ?? this.workoutId,
    exerciseId: exerciseId ?? this.exerciseId,
    position: position ?? this.position,
  );
  WorkoutExercise copyWithCompanion(WorkoutExercisesCompanion data) {
    return WorkoutExercise(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExercise(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, workoutId, exerciseId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutExercise &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.exerciseId == this.exerciseId &&
          other.position == this.position);
}

class WorkoutExercisesCompanion extends UpdateCompanion<WorkoutExercise> {
  final Value<int> id;
  final Value<int> workoutId;
  final Value<int> exerciseId;
  final Value<int> position;
  const WorkoutExercisesCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.position = const Value.absent(),
  });
  WorkoutExercisesCompanion.insert({
    this.id = const Value.absent(),
    required int workoutId,
    required int exerciseId,
    required int position,
  }) : workoutId = Value(workoutId),
       exerciseId = Value(exerciseId),
       position = Value(position);
  static Insertable<WorkoutExercise> custom({
    Expression<int>? id,
    Expression<int>? workoutId,
    Expression<int>? exerciseId,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (position != null) 'position': position,
    });
  }

  WorkoutExercisesCompanion copyWith({
    Value<int>? id,
    Value<int>? workoutId,
    Value<int>? exerciseId,
    Value<int>? position,
  }) {
    return WorkoutExercisesCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExercisesCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSetsTable extends WorkoutSets
    with TableInfo<$WorkoutSetsTable, WorkoutSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workoutExerciseIdMeta = const VerificationMeta(
    'workoutExerciseId',
  );
  @override
  late final GeneratedColumn<int> workoutExerciseId = GeneratedColumn<int>(
    'workout_exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_exercises (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isWarmupMeta = const VerificationMeta(
    'isWarmup',
  );
  @override
  late final GeneratedColumn<bool> isWarmup = GeneratedColumn<bool>(
    'is_warmup',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_warmup" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<double> rpe = GeneratedColumn<double>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<DateTime> doneAt = GeneratedColumn<DateTime>(
    'done_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutExerciseId,
    position,
    weight,
    reps,
    isWarmup,
    rpe,
    doneAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_exercise_id')) {
      context.handle(
        _workoutExerciseIdMeta,
        workoutExerciseId.isAcceptableOrUnknown(
          data['workout_exercise_id']!,
          _workoutExerciseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutExerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('is_warmup')) {
      context.handle(
        _isWarmupMeta,
        isWarmup.isAcceptableOrUnknown(data['is_warmup']!, _isWarmupMeta),
      );
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    if (data.containsKey('done_at')) {
      context.handle(
        _doneAtMeta,
        doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta),
      );
    } else if (isInserting) {
      context.missing(_doneAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workoutExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workout_exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      isWarmup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_warmup'],
      )!,
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rpe'],
      ),
      doneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}done_at'],
      )!,
    );
  }

  @override
  $WorkoutSetsTable createAlias(String alias) {
    return $WorkoutSetsTable(attachedDatabase, alias);
  }
}

class WorkoutSet extends DataClass implements Insertable<WorkoutSet> {
  final int id;
  final int workoutExerciseId;
  final int position;
  final double weight;
  final int reps;
  final bool isWarmup;
  final double? rpe;
  final DateTime doneAt;
  const WorkoutSet({
    required this.id,
    required this.workoutExerciseId,
    required this.position,
    required this.weight,
    required this.reps,
    required this.isWarmup,
    this.rpe,
    required this.doneAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workout_exercise_id'] = Variable<int>(workoutExerciseId);
    map['position'] = Variable<int>(position);
    map['weight'] = Variable<double>(weight);
    map['reps'] = Variable<int>(reps);
    map['is_warmup'] = Variable<bool>(isWarmup);
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<double>(rpe);
    }
    map['done_at'] = Variable<DateTime>(doneAt);
    return map;
  }

  WorkoutSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSetsCompanion(
      id: Value(id),
      workoutExerciseId: Value(workoutExerciseId),
      position: Value(position),
      weight: Value(weight),
      reps: Value(reps),
      isWarmup: Value(isWarmup),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      doneAt: Value(doneAt),
    );
  }

  factory WorkoutSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSet(
      id: serializer.fromJson<int>(json['id']),
      workoutExerciseId: serializer.fromJson<int>(json['workoutExerciseId']),
      position: serializer.fromJson<int>(json['position']),
      weight: serializer.fromJson<double>(json['weight']),
      reps: serializer.fromJson<int>(json['reps']),
      isWarmup: serializer.fromJson<bool>(json['isWarmup']),
      rpe: serializer.fromJson<double?>(json['rpe']),
      doneAt: serializer.fromJson<DateTime>(json['doneAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workoutExerciseId': serializer.toJson<int>(workoutExerciseId),
      'position': serializer.toJson<int>(position),
      'weight': serializer.toJson<double>(weight),
      'reps': serializer.toJson<int>(reps),
      'isWarmup': serializer.toJson<bool>(isWarmup),
      'rpe': serializer.toJson<double?>(rpe),
      'doneAt': serializer.toJson<DateTime>(doneAt),
    };
  }

  WorkoutSet copyWith({
    int? id,
    int? workoutExerciseId,
    int? position,
    double? weight,
    int? reps,
    bool? isWarmup,
    Value<double?> rpe = const Value.absent(),
    DateTime? doneAt,
  }) => WorkoutSet(
    id: id ?? this.id,
    workoutExerciseId: workoutExerciseId ?? this.workoutExerciseId,
    position: position ?? this.position,
    weight: weight ?? this.weight,
    reps: reps ?? this.reps,
    isWarmup: isWarmup ?? this.isWarmup,
    rpe: rpe.present ? rpe.value : this.rpe,
    doneAt: doneAt ?? this.doneAt,
  );
  WorkoutSet copyWithCompanion(WorkoutSetsCompanion data) {
    return WorkoutSet(
      id: data.id.present ? data.id.value : this.id,
      workoutExerciseId: data.workoutExerciseId.present
          ? data.workoutExerciseId.value
          : this.workoutExerciseId,
      position: data.position.present ? data.position.value : this.position,
      weight: data.weight.present ? data.weight.value : this.weight,
      reps: data.reps.present ? data.reps.value : this.reps,
      isWarmup: data.isWarmup.present ? data.isWarmup.value : this.isWarmup,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSet(')
          ..write('id: $id, ')
          ..write('workoutExerciseId: $workoutExerciseId, ')
          ..write('position: $position, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('isWarmup: $isWarmup, ')
          ..write('rpe: $rpe, ')
          ..write('doneAt: $doneAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutExerciseId,
    position,
    weight,
    reps,
    isWarmup,
    rpe,
    doneAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSet &&
          other.id == this.id &&
          other.workoutExerciseId == this.workoutExerciseId &&
          other.position == this.position &&
          other.weight == this.weight &&
          other.reps == this.reps &&
          other.isWarmup == this.isWarmup &&
          other.rpe == this.rpe &&
          other.doneAt == this.doneAt);
}

class WorkoutSetsCompanion extends UpdateCompanion<WorkoutSet> {
  final Value<int> id;
  final Value<int> workoutExerciseId;
  final Value<int> position;
  final Value<double> weight;
  final Value<int> reps;
  final Value<bool> isWarmup;
  final Value<double?> rpe;
  final Value<DateTime> doneAt;
  const WorkoutSetsCompanion({
    this.id = const Value.absent(),
    this.workoutExerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.weight = const Value.absent(),
    this.reps = const Value.absent(),
    this.isWarmup = const Value.absent(),
    this.rpe = const Value.absent(),
    this.doneAt = const Value.absent(),
  });
  WorkoutSetsCompanion.insert({
    this.id = const Value.absent(),
    required int workoutExerciseId,
    required int position,
    required double weight,
    required int reps,
    this.isWarmup = const Value.absent(),
    this.rpe = const Value.absent(),
    required DateTime doneAt,
  }) : workoutExerciseId = Value(workoutExerciseId),
       position = Value(position),
       weight = Value(weight),
       reps = Value(reps),
       doneAt = Value(doneAt);
  static Insertable<WorkoutSet> custom({
    Expression<int>? id,
    Expression<int>? workoutExerciseId,
    Expression<int>? position,
    Expression<double>? weight,
    Expression<int>? reps,
    Expression<bool>? isWarmup,
    Expression<double>? rpe,
    Expression<DateTime>? doneAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutExerciseId != null) 'workout_exercise_id': workoutExerciseId,
      if (position != null) 'position': position,
      if (weight != null) 'weight': weight,
      if (reps != null) 'reps': reps,
      if (isWarmup != null) 'is_warmup': isWarmup,
      if (rpe != null) 'rpe': rpe,
      if (doneAt != null) 'done_at': doneAt,
    });
  }

  WorkoutSetsCompanion copyWith({
    Value<int>? id,
    Value<int>? workoutExerciseId,
    Value<int>? position,
    Value<double>? weight,
    Value<int>? reps,
    Value<bool>? isWarmup,
    Value<double?>? rpe,
    Value<DateTime>? doneAt,
  }) {
    return WorkoutSetsCompanion(
      id: id ?? this.id,
      workoutExerciseId: workoutExerciseId ?? this.workoutExerciseId,
      position: position ?? this.position,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isWarmup: isWarmup ?? this.isWarmup,
      rpe: rpe ?? this.rpe,
      doneAt: doneAt ?? this.doneAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutExerciseId.present) {
      map['workout_exercise_id'] = Variable<int>(workoutExerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (isWarmup.present) {
      map['is_warmup'] = Variable<bool>(isWarmup.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<double>(rpe.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<DateTime>(doneAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetsCompanion(')
          ..write('id: $id, ')
          ..write('workoutExerciseId: $workoutExerciseId, ')
          ..write('position: $position, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('isWarmup: $isWarmup, ')
          ..write('rpe: $rpe, ')
          ..write('doneAt: $doneAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MusclesTable muscles = $MusclesTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $ExerciseMusclesTable exerciseMuscles = $ExerciseMusclesTable(
    this,
  );
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $WorkoutExercisesTable workoutExercises = $WorkoutExercisesTable(
    this,
  );
  late final $WorkoutSetsTable workoutSets = $WorkoutSetsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    muscles,
    exercises,
    exerciseMuscles,
    workouts,
    workoutExercises,
    workoutSets,
  ];
}

typedef $$MusclesTableCreateCompanionBuilder = MusclesCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$MusclesTableUpdateCompanionBuilder = MusclesCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$MusclesTableReferences
    extends BaseReferences<_$AppDatabase, $MusclesTable, Muscle> {
  $$MusclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExerciseMusclesTable, List<ExerciseMuscle>>
  _exerciseMusclesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseMuscles,
    aliasName: 'muscles__id__exercise_muscles__muscle_id',
  );

  $$ExerciseMusclesTableProcessedTableManager get exerciseMusclesRefs {
    final manager = $$ExerciseMusclesTableTableManager(
      $_db,
      $_db.exerciseMuscles,
    ).filter((f) => f.muscleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseMusclesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MusclesTableFilterComposer
    extends Composer<_$AppDatabase, $MusclesTable> {
  $$MusclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exerciseMusclesRefs(
    Expression<bool> Function($$ExerciseMusclesTableFilterComposer f) f,
  ) {
    final $$ExerciseMusclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscles,
      getReferencedColumn: (t) => t.muscleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMusclesTableFilterComposer(
            $db: $db,
            $table: $db.exerciseMuscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MusclesTableOrderingComposer
    extends Composer<_$AppDatabase, $MusclesTable> {
  $$MusclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MusclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MusclesTable> {
  $$MusclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> exerciseMusclesRefs<T extends Object>(
    Expression<T> Function($$ExerciseMusclesTableAnnotationComposer a) f,
  ) {
    final $$ExerciseMusclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscles,
      getReferencedColumn: (t) => t.muscleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMusclesTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseMuscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MusclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MusclesTable,
          Muscle,
          $$MusclesTableFilterComposer,
          $$MusclesTableOrderingComposer,
          $$MusclesTableAnnotationComposer,
          $$MusclesTableCreateCompanionBuilder,
          $$MusclesTableUpdateCompanionBuilder,
          (Muscle, $$MusclesTableReferences),
          Muscle,
          PrefetchHooks Function({bool exerciseMusclesRefs})
        > {
  $$MusclesTableTableManager(_$AppDatabase db, $MusclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MusclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MusclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MusclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) => MusclesCompanion(id: id, name: name),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) => MusclesCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MusclesTable, Muscle>(table),
                  $$MusclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseMusclesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (exerciseMusclesRefs) db.exerciseMuscles,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exerciseMusclesRefs)
                    await $_getPrefetchedDataByColumns<
                      Muscle,
                      $MusclesTable,
                      ExerciseMuscle,
                      $ExerciseMusclesTable
                    >(
                      currentTable: table,
                      referencedTable: $$MusclesTableReferences
                          ._exerciseMusclesRefsTable(db),
                      managerFromTypedResult: (p0) => $$MusclesTableReferences(
                        db,
                        table,
                        p0,
                      ).exerciseMusclesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'muscle_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MusclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MusclesTable,
      Muscle,
      $$MusclesTableFilterComposer,
      $$MusclesTableOrderingComposer,
      $$MusclesTableAnnotationComposer,
      $$MusclesTableCreateCompanionBuilder,
      $$MusclesTableUpdateCompanionBuilder,
      (Muscle, $$MusclesTableReferences),
      Muscle,
      PrefetchHooks Function({bool exerciseMusclesRefs})
    >;
typedef $$ExercisesTableCreateCompanionBuilder = ExercisesCompanion Function({
  Value<int> id,
  required String name,
  required String equipment,
  Value<bool> isCustom,
});
typedef $$ExercisesTableUpdateCompanionBuilder = ExercisesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> equipment,
  Value<bool> isCustom,
});

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExerciseMusclesTable, List<ExerciseMuscle>>
  _exerciseMusclesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseMuscles,
    aliasName: 'exercises__id__exercise_muscles__exercise_id',
  );

  $$ExerciseMusclesTableProcessedTableManager get exerciseMusclesRefs {
    final manager = $$ExerciseMusclesTableTableManager(
      $_db,
      $_db.exerciseMuscles,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseMusclesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutExercisesTable, List<WorkoutExercise>>
  _workoutExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutExercises,
    aliasName: 'exercises__id__workout_exercises__exercise_id',
  );

  $$WorkoutExercisesTableProcessedTableManager get workoutExercisesRefs {
    final manager = $$WorkoutExercisesTableTableManager(
      $_db,
      $_db.workoutExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exerciseMusclesRefs(
    Expression<bool> Function($$ExerciseMusclesTableFilterComposer f) f,
  ) {
    final $$ExerciseMusclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscles,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMusclesTableFilterComposer(
            $db: $db,
            $table: $db.exerciseMuscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutExercisesRefs(
    Expression<bool> Function($$WorkoutExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  Expression<T> exerciseMusclesRefs<T extends Object>(
    Expression<T> Function($$ExerciseMusclesTableAnnotationComposer a) f,
  ) {
    final $$ExerciseMusclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscles,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMusclesTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseMuscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workoutExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutExercisesTableAnnotationComposer a) f,
  ) {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({
            bool exerciseMusclesRefs,
            bool workoutExercisesRefs,
          })
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> equipment = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                name: name,
                equipment: equipment,
                isCustom: isCustom,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String equipment,
                Value<bool> isCustom = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                name: name,
                equipment: equipment,
                isCustom: isCustom,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExercisesTable, Exercise>(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({exerciseMusclesRefs = false, workoutExercisesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseMusclesRefs) db.exerciseMuscles,
                    if (workoutExercisesRefs) db.workoutExercises,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseMusclesRefs)
                        await $_getPrefetchedDataByColumns<
                          Exercise,
                          $ExercisesTable,
                          ExerciseMuscle,
                          $ExerciseMusclesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseMusclesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseMusclesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_id',
                          typedResults: items,
                        ),
                      if (workoutExercisesRefs)
                        await $_getPrefetchedDataByColumns<
                          Exercise,
                          $ExercisesTable,
                          WorkoutExercise,
                          $WorkoutExercisesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._workoutExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutExercisesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({
        bool exerciseMusclesRefs,
        bool workoutExercisesRefs,
      })
    >;
typedef $$ExerciseMusclesTableCreateCompanionBuilder =
    ExerciseMusclesCompanion Function({
      required int exerciseId,
      required int muscleId,
      required double share,
      Value<int> rowid,
    });
typedef $$ExerciseMusclesTableUpdateCompanionBuilder =
    ExerciseMusclesCompanion Function({
      Value<int> exerciseId,
      Value<int> muscleId,
      Value<double> share,
      Value<int> rowid,
    });

final class $$ExerciseMusclesTableReferences
    extends
        BaseReferences<_$AppDatabase, $ExerciseMusclesTable, ExerciseMuscle> {
  $$ExerciseMusclesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('exercise_muscles__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MusclesTable _muscleIdTable(_$AppDatabase db) =>
      db.muscles.createAlias('exercise_muscles__muscle_id__muscles__id');

  $$MusclesTableProcessedTableManager get muscleId {
    final $_column = $_itemColumn<int>('muscle_id')!;

    final manager = $$MusclesTableTableManager(
      $_db,
      $_db.muscles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_muscleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseMusclesTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get share => $composableBuilder(
    column: $table.share,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MusclesTableFilterComposer get muscleId {
    final $$MusclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleId,
      referencedTable: $db.muscles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MusclesTableFilterComposer(
            $db: $db,
            $table: $db.muscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMusclesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get share => $composableBuilder(
    column: $table.share,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MusclesTableOrderingComposer get muscleId {
    final $$MusclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleId,
      referencedTable: $db.muscles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MusclesTableOrderingComposer(
            $db: $db,
            $table: $db.muscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMusclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get share =>
      $composableBuilder(column: $table.share, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MusclesTableAnnotationComposer get muscleId {
    final $$MusclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleId,
      referencedTable: $db.muscles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MusclesTableAnnotationComposer(
            $db: $db,
            $table: $db.muscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMusclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseMusclesTable,
          ExerciseMuscle,
          $$ExerciseMusclesTableFilterComposer,
          $$ExerciseMusclesTableOrderingComposer,
          $$ExerciseMusclesTableAnnotationComposer,
          $$ExerciseMusclesTableCreateCompanionBuilder,
          $$ExerciseMusclesTableUpdateCompanionBuilder,
          (ExerciseMuscle, $$ExerciseMusclesTableReferences),
          ExerciseMuscle,
          PrefetchHooks Function({bool exerciseId, bool muscleId})
        > {
  $$ExerciseMusclesTableTableManager(
    _$AppDatabase db,
    $ExerciseMusclesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseMusclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseMusclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseMusclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> exerciseId = const Value.absent(),
                Value<int> muscleId = const Value.absent(),
                Value<double> share = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMusclesCompanion(
                exerciseId: exerciseId,
                muscleId: muscleId,
                share: share,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int exerciseId,
                required int muscleId,
                required double share,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMusclesCompanion.insert(
                exerciseId: exerciseId,
                muscleId: muscleId,
                share: share,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExerciseMusclesTable, ExerciseMuscle>(table),
                  $$ExerciseMusclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false, muscleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (exerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.exerciseId,
                        referencedTable: $$ExerciseMusclesTableReferences
                            ._exerciseIdTable(db),
                        referencedColumn: $$ExerciseMusclesTableReferences
                            ._exerciseIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (muscleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.muscleId,
                        referencedTable: $$ExerciseMusclesTableReferences
                            ._muscleIdTable(db),
                        referencedColumn: $$ExerciseMusclesTableReferences
                            ._muscleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExerciseMusclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseMusclesTable,
      ExerciseMuscle,
      $$ExerciseMusclesTableFilterComposer,
      $$ExerciseMusclesTableOrderingComposer,
      $$ExerciseMusclesTableAnnotationComposer,
      $$ExerciseMusclesTableCreateCompanionBuilder,
      $$ExerciseMusclesTableUpdateCompanionBuilder,
      (ExerciseMuscle, $$ExerciseMusclesTableReferences),
      ExerciseMuscle,
      PrefetchHooks Function({bool exerciseId, bool muscleId})
    >;
typedef $$WorkoutsTableCreateCompanionBuilder = WorkoutsCompanion Function({
  Value<int> id,
  required DateTime startedAt,
  Value<DateTime?> finishedAt,
  Value<String?> note,
});
typedef $$WorkoutsTableUpdateCompanionBuilder = WorkoutsCompanion Function({
  Value<int> id,
  Value<DateTime> startedAt,
  Value<DateTime?> finishedAt,
  Value<String?> note,
});

final class $$WorkoutsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutsTable, Workout> {
  $$WorkoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkoutExercisesTable, List<WorkoutExercise>>
  _workoutExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutExercises,
    aliasName: 'workouts__id__workout_exercises__workout_id',
  );

  $$WorkoutExercisesTableProcessedTableManager get workoutExercisesRefs {
    final manager = $$WorkoutExercisesTableTableManager(
      $_db,
      $_db.workoutExercises,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workoutExercisesRefs(
    Expression<bool> Function($$WorkoutExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  Expression<T> workoutExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutExercisesTableAnnotationComposer a) f,
  ) {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutsTable,
          Workout,
          $$WorkoutsTableFilterComposer,
          $$WorkoutsTableOrderingComposer,
          $$WorkoutsTableAnnotationComposer,
          $$WorkoutsTableCreateCompanionBuilder,
          $$WorkoutsTableUpdateCompanionBuilder,
          (Workout, $$WorkoutsTableReferences),
          Workout,
          PrefetchHooks Function({bool workoutExercisesRefs})
        > {
  $$WorkoutsTableTableManager(_$AppDatabase db, $WorkoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => WorkoutsCompanion(
                id: id,
                startedAt: startedAt,
                finishedAt: finishedAt,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => WorkoutsCompanion.insert(
                id: id,
                startedAt: startedAt,
                finishedAt: finishedAt,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutsTable, Workout>(table),
                  $$WorkoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutExercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workoutExercisesRefs) db.workoutExercises,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutExercisesRefs)
                    await $_getPrefetchedDataByColumns<
                      Workout,
                      $WorkoutsTable,
                      WorkoutExercise,
                      $WorkoutExercisesTable
                    >(
                      currentTable: table,
                      referencedTable: $$WorkoutsTableReferences
                          ._workoutExercisesRefsTable(db),
                      managerFromTypedResult: (p0) => $$WorkoutsTableReferences(
                        db,
                        table,
                        p0,
                      ).workoutExercisesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'workout_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutsTable,
      Workout,
      $$WorkoutsTableFilterComposer,
      $$WorkoutsTableOrderingComposer,
      $$WorkoutsTableAnnotationComposer,
      $$WorkoutsTableCreateCompanionBuilder,
      $$WorkoutsTableUpdateCompanionBuilder,
      (Workout, $$WorkoutsTableReferences),
      Workout,
      PrefetchHooks Function({bool workoutExercisesRefs})
    >;
typedef $$WorkoutExercisesTableCreateCompanionBuilder =
    WorkoutExercisesCompanion Function({
      Value<int> id,
      required int workoutId,
      required int exerciseId,
      required int position,
    });
typedef $$WorkoutExercisesTableUpdateCompanionBuilder =
    WorkoutExercisesCompanion Function({
      Value<int> id,
      Value<int> workoutId,
      Value<int> exerciseId,
      Value<int> position,
    });

final class $$WorkoutExercisesTableReferences
    extends
        BaseReferences<_$AppDatabase, $WorkoutExercisesTable, WorkoutExercise> {
  $$WorkoutExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias('workout_exercises__workout_id__workouts__id');

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<int>('workout_id')!;

    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('workout_exercises__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WorkoutSetsTable, List<WorkoutSet>>
  _workoutSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutSets,
    aliasName: 'workout_exercises__id__workout_sets__workout_exercise_id',
  );

  $$WorkoutSetsTableProcessedTableManager get workoutSetsRefs {
    final manager = $$WorkoutSetsTableTableManager(
      $_db,
      $_db.workoutSets,
    ).filter((f) => f.workoutExerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> workoutSetsRefs(
    Expression<bool> Function($$WorkoutSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.workoutExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> workoutSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.workoutExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutExercisesTable,
          WorkoutExercise,
          $$WorkoutExercisesTableFilterComposer,
          $$WorkoutExercisesTableOrderingComposer,
          $$WorkoutExercisesTableAnnotationComposer,
          $$WorkoutExercisesTableCreateCompanionBuilder,
          $$WorkoutExercisesTableUpdateCompanionBuilder,
          (WorkoutExercise, $$WorkoutExercisesTableReferences),
          WorkoutExercise,
          PrefetchHooks Function({
            bool workoutId,
            bool exerciseId,
            bool workoutSetsRefs,
          })
        > {
  $$WorkoutExercisesTableTableManager(
    _$AppDatabase db,
    $WorkoutExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workoutId = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => WorkoutExercisesCompanion(
                id: id,
                workoutId: workoutId,
                exerciseId: exerciseId,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workoutId,
                required int exerciseId,
                required int position,
              }) => WorkoutExercisesCompanion.insert(
                id: id,
                workoutId: workoutId,
                exerciseId: exerciseId,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutExercisesTable, WorkoutExercise>(table),
                  $$WorkoutExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutId = false,
                exerciseId = false,
                workoutSetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutSetsRefs) db.workoutSets,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workoutId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.workoutId,
                            referencedTable: $$WorkoutExercisesTableReferences
                                ._workoutIdTable(db),
                            referencedColumn: $$WorkoutExercisesTableReferences
                                ._workoutIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (exerciseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.exerciseId,
                            referencedTable: $$WorkoutExercisesTableReferences
                                ._exerciseIdTable(db),
                            referencedColumn: $$WorkoutExercisesTableReferences
                                ._exerciseIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutSetsRefs)
                        await $_getPrefetchedDataByColumns<
                          WorkoutExercise,
                          $WorkoutExercisesTable,
                          WorkoutSet,
                          $WorkoutSetsTable
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutExercisesTableReferences
                              ._workoutSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSetsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'workout_exercise_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutExercisesTable,
      WorkoutExercise,
      $$WorkoutExercisesTableFilterComposer,
      $$WorkoutExercisesTableOrderingComposer,
      $$WorkoutExercisesTableAnnotationComposer,
      $$WorkoutExercisesTableCreateCompanionBuilder,
      $$WorkoutExercisesTableUpdateCompanionBuilder,
      (WorkoutExercise, $$WorkoutExercisesTableReferences),
      WorkoutExercise,
      PrefetchHooks Function({
        bool workoutId,
        bool exerciseId,
        bool workoutSetsRefs,
      })
    >;
typedef $$WorkoutSetsTableCreateCompanionBuilder =
    WorkoutSetsCompanion Function({
      Value<int> id,
      required int workoutExerciseId,
      required int position,
      required double weight,
      required int reps,
      Value<bool> isWarmup,
      Value<double?> rpe,
      required DateTime doneAt,
    });
typedef $$WorkoutSetsTableUpdateCompanionBuilder =
    WorkoutSetsCompanion Function({
      Value<int> id,
      Value<int> workoutExerciseId,
      Value<int> position,
      Value<double> weight,
      Value<int> reps,
      Value<bool> isWarmup,
      Value<double?> rpe,
      Value<DateTime> doneAt,
    });

final class $$WorkoutSetsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutSetsTable, WorkoutSet> {
  $$WorkoutSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutExercisesTable _workoutExerciseIdTable(_$AppDatabase db) => db
      .workoutExercises
      .createAlias('workout_sets__workout_exercise_id__workout_exercises__id');

  $$WorkoutExercisesTableProcessedTableManager get workoutExerciseId {
    final $_column = $_itemColumn<int>('workout_exercise_id')!;

    final manager = $$WorkoutExercisesTableTableManager(
      $_db,
      $_db.workoutExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWarmup => $composableBuilder(
    column: $table.isWarmup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutExercisesTableFilterComposer get workoutExerciseId {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutExerciseId,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWarmup => $composableBuilder(
    column: $table.isWarmup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutExercisesTableOrderingComposer get workoutExerciseId {
    final $$WorkoutExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutExerciseId,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<bool> get isWarmup =>
      $composableBuilder(column: $table.isWarmup, builder: (column) => column);

  GeneratedColumn<double> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<DateTime> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);

  $$WorkoutExercisesTableAnnotationComposer get workoutExerciseId {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutExerciseId,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSetsTable,
          WorkoutSet,
          $$WorkoutSetsTableFilterComposer,
          $$WorkoutSetsTableOrderingComposer,
          $$WorkoutSetsTableAnnotationComposer,
          $$WorkoutSetsTableCreateCompanionBuilder,
          $$WorkoutSetsTableUpdateCompanionBuilder,
          (WorkoutSet, $$WorkoutSetsTableReferences),
          WorkoutSet,
          PrefetchHooks Function({bool workoutExerciseId})
        > {
  $$WorkoutSetsTableTableManager(_$AppDatabase db, $WorkoutSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workoutExerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<bool> isWarmup = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<DateTime> doneAt = const Value.absent(),
              }) => WorkoutSetsCompanion(
                id: id,
                workoutExerciseId: workoutExerciseId,
                position: position,
                weight: weight,
                reps: reps,
                isWarmup: isWarmup,
                rpe: rpe,
                doneAt: doneAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workoutExerciseId,
                required int position,
                required double weight,
                required int reps,
                Value<bool> isWarmup = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                required DateTime doneAt,
              }) => WorkoutSetsCompanion.insert(
                id: id,
                workoutExerciseId: workoutExerciseId,
                position: position,
                weight: weight,
                reps: reps,
                isWarmup: isWarmup,
                rpe: rpe,
                doneAt: doneAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutSetsTable, WorkoutSet>(table),
                  $$WorkoutSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutExerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workoutExerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.workoutExerciseId,
                        referencedTable: $$WorkoutSetsTableReferences
                            ._workoutExerciseIdTable(db),
                        referencedColumn: $$WorkoutSetsTableReferences
                            ._workoutExerciseIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSetsTable,
      WorkoutSet,
      $$WorkoutSetsTableFilterComposer,
      $$WorkoutSetsTableOrderingComposer,
      $$WorkoutSetsTableAnnotationComposer,
      $$WorkoutSetsTableCreateCompanionBuilder,
      $$WorkoutSetsTableUpdateCompanionBuilder,
      (WorkoutSet, $$WorkoutSetsTableReferences),
      WorkoutSet,
      PrefetchHooks Function({bool workoutExerciseId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MusclesTableTableManager get muscles =>
      $$MusclesTableTableManager(_db, _db.muscles);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$ExerciseMusclesTableTableManager get exerciseMuscles =>
      $$ExerciseMusclesTableTableManager(_db, _db.exerciseMuscles);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db, _db.workouts);
  $$WorkoutExercisesTableTableManager get workoutExercises =>
      $$WorkoutExercisesTableTableManager(_db, _db.workoutExercises);
  $$WorkoutSetsTableTableManager get workoutSets =>
      $$WorkoutSetsTableTableManager(_db, _db.workoutSets);
}
