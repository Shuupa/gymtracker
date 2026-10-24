import 'package:drift/drift.dart';

import '../data/app_database.dart';
import 'one_rm.dart';

class ReportExercise {
  final Exercise exercise;
  final List<WorkoutSet> sets; // только рабочие
  const ReportExercise(this.exercise, this.sets);

  double get volume => sets.fold(0.0, (s, e) => s + e.weight * e.reps);

  double get best1rm {
    var m = 0.0;
    for (final s in sets) {
      final v = oneRm(s.weight, s.reps);
      if (v > m) m = v;
    }
    return m;
  }
}

class WorkoutReport {
  final Workout workout;
  final List<ReportExercise> exercises;

  /// «Эффективные подходы» по мышцам: сумма (доля мышцы × число подходов)
  final Map<String, double> muscleLoad;

  const WorkoutReport(this.workout, this.exercises, this.muscleLoad);

  int get setCount => exercises.fold(0, (s, e) => s + e.sets.length);
  double get volume => exercises.fold(0.0, (s, e) => s + e.volume);
  Duration get duration =>
      (workout.finishedAt ?? DateTime.now()).difference(workout.startedAt);
}

Future<WorkoutReport?> buildReport(AppDatabase db, int workoutId) async {
  final workout = await (db.select(
    db.workouts,
  )..where((w) => w.id.equals(workoutId))).getSingleOrNull();
  if (workout == null) return null;

  final rows =
      await (db.select(db.workoutExercises).join([
              innerJoin(
                db.exercises,
                db.exercises.id.equalsExp(db.workoutExercises.exerciseId),
              ),
            ])
            ..where(db.workoutExercises.workoutId.equals(workoutId))
            ..orderBy([OrderingTerm.asc(db.workoutExercises.position)]))
          .get();

  final links = await db.exerciseMuscleLinks();
  final exercises = <ReportExercise>[];
  final load = <String, double>{};

  for (final r in rows) {
    final we = r.readTable(db.workoutExercises);
    final ex = r.readTable(db.exercises);
    final sets =
        await (db.select(db.workoutSets)
              ..where(
                (s) =>
                    s.workoutExerciseId.equals(we.id) &
                    s.isWarmup.equals(false),
              )
              ..orderBy([(s) => OrderingTerm.asc(s.position)]))
            .get();
    if (sets.isEmpty) continue;
    exercises.add(ReportExercise(ex, sets));
    for (final l in links.where((l) => l.exerciseId == ex.id)) {
      load[l.muscle] = (load[l.muscle] ?? 0) + l.share * sets.length;
    }
  }
  return WorkoutReport(workout, exercises, load);
}
