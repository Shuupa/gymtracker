import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'logic/summaries.dart';
import 'logic/report.dart';
import 'logic/one_rm.dart';
import 'data/app_database.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final exercisesProvider = StreamProvider<List<Exercise>>((ref) {
  return ref.watch(dbProvider).select(ref.watch(dbProvider).exercises).watch();
});
final workoutsProvider = StreamProvider<List<Workout>>(
  (ref) => ref.watch(dbProvider).watchWorkouts(),
);

final workoutExercisesProvider =
    StreamProvider.family<List<({WorkoutExercise we, Exercise ex})>, int>(
      (ref, workoutId) =>
          ref.watch(dbProvider).watchWorkoutExercises(workoutId),
    );

final setsProvider = StreamProvider.family<List<WorkoutSet>, int>(
  (ref, weId) => ref.watch(dbProvider).watchSets(weId),
);
final exerciseHistoryProvider = FutureProvider.autoDispose
    .family<List<Session>, int>(
      (ref, exerciseId) => ref.read(dbProvider).exerciseHistory(exerciseId),
    );
final workoutProvider = StreamProvider.family<Workout?, int>((ref, id) {
  final db = ref.watch(dbProvider);
  return (db.select(
    db.workouts,
  )..where((w) => w.id.equals(id))).watchSingleOrNull();
});

final workoutSummariesProvider = StreamProvider<List<WorkoutSummary>>((ref) {
  final db = ref.watch(dbProvider);
  return db
      .customSelect(
        'SELECT 1',
        readsFrom: {db.workouts, db.workoutExercises, db.workoutSets},
      )
      .watch()
      .asyncMap((_) => loadSummaries(db));
});

final reportProvider = StreamProvider.autoDispose.family<WorkoutReport?, int>((
  ref,
  id,
) {
  final db = ref.watch(dbProvider);
  return db
      .customSelect(
        'SELECT 1',
        readsFrom: {db.workouts, db.workoutExercises, db.workoutSets},
      )
      .watch()
      .asyncMap((_) => buildReport(db, id));
});
