import 'package:drift/drift.dart';

import '../data/app_database.dart';

class WorkoutSummary {
  final Workout workout;
  final int exerciseCount;
  final int setCount;
  final double volume;
  final List<String> exerciseNames;
  const WorkoutSummary({
    required this.workout,
    required this.exerciseCount,
    required this.setCount,
    required this.volume,
    required this.exerciseNames,
  });

  bool get isFinished => workout.finishedAt != null;
  Duration? get duration => workout.finishedAt?.difference(workout.startedAt);
}

Future<List<WorkoutSummary>> loadSummaries(AppDatabase db) async {
  final ws = await (db.select(
    db.workouts,
  )..orderBy([(w) => OrderingTerm.desc(w.startedAt)])).get();

  final exRows = await (db.select(db.workoutExercises).join([
    innerJoin(
      db.exercises,
      db.exercises.id.equalsExp(db.workoutExercises.exerciseId),
    ),
  ])..orderBy([OrderingTerm.asc(db.workoutExercises.position)])).get();

  final setRows = await (db.select(db.workoutSets).join([
    innerJoin(
      db.workoutExercises,
      db.workoutExercises.id.equalsExp(db.workoutSets.workoutExerciseId),
    ),
  ])..where(db.workoutSets.isWarmup.equals(false))).get();

  final names = <int, List<String>>{};
  for (final r in exRows) {
    final we = r.readTable(db.workoutExercises);
    (names[we.workoutId] ??= []).add(r.readTable(db.exercises).name);
  }
  final setCount = <int, int>{};
  final volume = <int, double>{};
  for (final r in setRows) {
    final wid = r.readTable(db.workoutExercises).workoutId;
    final s = r.readTable(db.workoutSets);
    setCount[wid] = (setCount[wid] ?? 0) + 1;
    volume[wid] = (volume[wid] ?? 0) + s.weight * s.reps;
  }

  return [
    for (final w in ws)
      WorkoutSummary(
        workout: w,
        exerciseCount: names[w.id]?.length ?? 0,
        setCount: setCount[w.id] ?? 0,
        volume: volume[w.id] ?? 0,
        exerciseNames: names[w.id] ?? const [],
      ),
  ];
}
