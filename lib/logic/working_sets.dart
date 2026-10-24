import 'package:drift/drift.dart';

import '../data/app_database.dart';
import 'one_rm.dart';

/// Все рабочие подходы из ЗАВЕРШЁННЫХ тренировок, сгруппированные по упражнению.
Future<Map<int, List<SetData>>> loadWorkingSets(AppDatabase db) async {
  final q =
      db.select(db.workoutSets).join([
        innerJoin(
          db.workoutExercises,
          db.workoutExercises.id.equalsExp(db.workoutSets.workoutExerciseId),
        ),
        innerJoin(
          db.workouts,
          db.workouts.id.equalsExp(db.workoutExercises.workoutId),
        ),
      ])..where(
        db.workouts.finishedAt.isNotNull() &
            db.workoutSets.isWarmup.equals(false),
      );

  final res = <int, List<SetData>>{};
  for (final r in await q.get()) {
    final exId = r.readTable(db.workoutExercises).exerciseId;
    final s = r.readTable(db.workoutSets);
    (res[exId] ??= []).add((weight: s.weight, reps: s.reps));
  }
  return res;
}
