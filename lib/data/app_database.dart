import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../logic/muscle_strength.dart';
import '../logic/one_rm.dart';
import 'tables.dart';
import 'seed.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Muscles,
    Exercises,
    ExerciseMuscles,
    Workouts,
    WorkoutExercises,
    WorkoutSets,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'gymtracker'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await syncSeed(this);
    },
    onUpgrade: (m, from, to) async {
      await syncSeed(this);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // Каталог подтягивается при каждом запуске, а не только при смене версии
      // схемы, поэтому новые упражнения появляются и в уже созданной базе.
      if (!details.wasCreated) await syncSeed(this);
    },
  );

  // ---------- тренировки ----------
  Stream<List<Workout>> watchWorkouts() => (select(
    workouts,
  )..orderBy([(w) => OrderingTerm.desc(w.startedAt)])).watch();

  Future<int> startWorkout() =>
      into(workouts)
          .insert(WorkoutsCompanion.insert(startedAt: DateTime.now()));

  Future<void> finishWorkout(int id) =>
      (update(workouts)..where((w) => w.id.equals(id) & w.finishedAt.isNull()))
          .write(WorkoutsCompanion(finishedAt: Value(DateTime.now())));

  Future<void> deleteWorkout(int id) => transaction(() async {
    final weIds = await (select(
      workoutExercises,
    )..where((e) => e.workoutId.equals(id))).map((e) => e.id).get();
    await (delete(
      workoutSets,
    )..where((s) => s.workoutExerciseId.isIn(weIds))).go();
    await (delete(workoutExercises)..where((e) => e.workoutId.equals(id))).go();
    await (delete(workouts)..where((w) => w.id.equals(id))).go();
  });

  Future<Set<int>> workoutExerciseIds(int workoutId) async =>
      (await (select(
            workoutExercises,
          )..where((e) => e.workoutId.equals(workoutId))).get())
          .map((row) => row.exerciseId)
          .toSet();

  Stream<List<({WorkoutExercise we, Exercise ex})>> watchWorkoutExercises(
    int workoutId,
  ) {
    final q =
        select(workoutExercises).join([
            innerJoin(
              exercises,
              exercises.id.equalsExp(workoutExercises.exerciseId),
            ),
          ])
          ..where(workoutExercises.workoutId.equals(workoutId))
          ..orderBy([OrderingTerm.asc(workoutExercises.position)]);
    return q.watch().map(
      (rows) => rows
          .map(
            (r) =>
                (we: r.readTable(workoutExercises), ex: r.readTable(exercises)),
          )
          .toList(),
    );
  }

  Future<int> addExerciseToWorkout(int workoutId, int exerciseId) async {
    final maxPos = workoutExercises.position.max();
    final row =
        await (selectOnly(workoutExercises)
              ..addColumns([maxPos])
              ..where(workoutExercises.workoutId.equals(workoutId)))
            .getSingle();
    final next = (row.read(maxPos) ?? -1) + 1;
    return into(workoutExercises).insert(
      WorkoutExercisesCompanion.insert(
        workoutId: workoutId,
        exerciseId: exerciseId,
        position: next,
      ),
    );
  }

  /// Удаляет упражнение из тренировки вместе с его подходами.
  Future<void> deleteWorkoutExercise(int id) => transaction(() async {
    await (delete(
      workoutSets,
    )..where((s) => s.workoutExerciseId.equals(id))).go();
    await (delete(workoutExercises)..where((e) => e.id.equals(id))).go();
  });

  Future<List<MuscleLink>> exerciseMuscleLinks() async {
    final q = select(exerciseMuscles).join([
      innerJoin(exercises, exercises.id.equalsExp(exerciseMuscles.exerciseId)),
      innerJoin(muscles, muscles.id.equalsExp(exerciseMuscles.muscleId)),
    ]);
    return (await q.get())
        .map(
          (r) => (
            muscle: r.readTable(muscles).name,
            exerciseId: r.readTable(exercises).id,
            exercise: r.readTable(exercises).name,
            equipment: r.readTable(exercises).equipment,
            share: r.readTable(exerciseMuscles).share,
          ),
        )
        .toList();
  }

  // ---------- подходы ----------
  Stream<List<WorkoutSet>> watchSets(int workoutExerciseId) =>
      (select(workoutSets)
            ..where((s) => s.workoutExerciseId.equals(workoutExerciseId))
            ..orderBy([(s) => OrderingTerm.asc(s.position)]))
          .watch();

  Future<void> addSet(
    int workoutExerciseId,
    double weight,
    int reps, {
    bool isWarmup = false,
  }) async {
    final maxPos = workoutSets.position.max();
    final row =
        await (selectOnly(workoutSets)
              ..addColumns([maxPos])
              ..where(workoutSets.workoutExerciseId.equals(workoutExerciseId)))
            .getSingle();
    final next = (row.read(maxPos) ?? -1) + 1;
    await into(workoutSets).insert(
      WorkoutSetsCompanion.insert(
        workoutExerciseId: workoutExerciseId,
        position: next,
        weight: weight,
        reps: reps,
        isWarmup: Value(isWarmup),
        doneAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteSet(int id) =>
      (delete(workoutSets)..where((s) => s.id.equals(id))).go();

  /// Подходы из последней ЗАВЕРШЁННОЙ тренировки, где было это упражнение.
  Future<List<WorkoutSet>> lastSetsFor(
    int exerciseId,
    int currentWorkoutId,
  ) async {
    final q =
        select(workoutExercises).join([
            innerJoin(
              workouts,
              workouts.id.equalsExp(workoutExercises.workoutId),
            ),
          ])
          ..where(
            workoutExercises.exerciseId.equals(exerciseId) &
                workoutExercises.workoutId.equals(currentWorkoutId).not() &
                workouts.finishedAt.isNotNull(),
          )
          ..orderBy([OrderingTerm.desc(workouts.startedAt)])
          ..limit(1);
    final row = await q.getSingleOrNull();
    if (row == null) return [];
    final weId = row.readTable(workoutExercises).id;
    return (select(workoutSets)
          ..where(
            (s) => s.workoutExerciseId.equals(weId) & s.isWarmup.equals(false),
          )
          ..orderBy([(s) => OrderingTerm.asc(s.position)]))
        .get();
  }

  /// Все завершённые тренировки с этим упражнением (без разминки), по возрастанию даты.
  Future<List<Session>> exerciseHistory(int exerciseId) async {
    final q =
        select(workoutSets).join([
            innerJoin(
              workoutExercises,
              workoutExercises.id.equalsExp(workoutSets.workoutExerciseId),
            ),
            innerJoin(
              workouts,
              workouts.id.equalsExp(workoutExercises.workoutId),
            ),
          ])
          ..where(
            workoutExercises.exerciseId.equals(exerciseId) &
                workouts.finishedAt.isNotNull() &
                workoutSets.isWarmup.equals(false),
          )
          ..orderBy([
            OrderingTerm.asc(workouts.startedAt),
            OrderingTerm.asc(workoutSets.position),
          ]);

    final byWorkout = <int, Session>{};
    for (final row in await q.get()) {
      final w = row.readTable(workouts);
      final s = row.readTable(workoutSets);
      byWorkout.putIfAbsent(w.id, () => Session(w.startedAt, [])).sets.add((
        weight: s.weight,
        reps: s.reps,
      ));
    }
    return byWorkout.values.toList(); // Map сохраняет порядок вставки
  }
}
