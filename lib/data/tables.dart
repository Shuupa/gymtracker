import 'package:drift/drift.dart';

class Muscles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get equipment =>
      text()(); // barbell, dumbbell, machine, bodyweight
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
}

class ExerciseMuscles extends Table {
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get muscleId => integer().references(Muscles, #id)();
  RealColumn get share => real()(); // доля нагрузки 0..1

  @override
  Set<Column> get primaryKey => {exerciseId, muscleId};
}

class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();
}

class WorkoutExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutId => integer().references(Workouts, #id)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get position => integer()();
}

class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutExerciseId =>
      integer().references(WorkoutExercises, #id)();
  IntColumn get position => integer()();
  RealColumn get weight => real()();
  IntColumn get reps => integer()();
  BoolColumn get isWarmup => boolean().withDefault(const Constant(false))();
  RealColumn get rpe => real().nullable()();
  DateTimeColumn get doneAt => dateTime()();
}
