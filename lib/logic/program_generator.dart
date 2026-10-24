import 'dart:math' as math;

import '../data/app_database.dart';
import '../data/seed.dart';
import 'muscle_strength.dart';

enum ProgramGoal { hypertrophy, strength, general }

enum TrainingLevel { beginner, intermediate, advanced }

String goalLabel(ProgramGoal goal) => switch (goal) {
  ProgramGoal.hypertrophy => 'Рост мышц',
  ProgramGoal.strength => 'Сила',
  ProgramGoal.general => 'Общее развитие',
};

String levelLabel(TrainingLevel level) => switch (level) {
  TrainingLevel.beginner => 'Начинающий',
  TrainingLevel.intermediate => 'Средний',
  TrainingLevel.advanced => 'Опытный',
};

class ProgramOptions {
  final ProgramGoal goal;
  final TrainingLevel level;
  final int daysPerWeek;
  final int sessionMinutes;
  final Set<String> excludedMuscles;
  final Set<String> priorityMuscles;
  final Set<int> excludedExerciseIds;
  final Set<int> priorityExerciseIds;
  final Set<String> equipment;
  final bool autoPrioritize;

  const ProgramOptions({
    required this.goal,
    required this.level,
    required this.daysPerWeek,
    required this.sessionMinutes,
    required this.excludedMuscles,
    required this.priorityMuscles,
    required this.excludedExerciseIds,
    required this.priorityExerciseIds,
    required this.equipment,
    required this.autoPrioritize,
  });
}

class PrescribedExercise {
  final int exerciseId;
  final String name;
  final String equipment;
  final String focus;
  final int sets;
  final int repMin;
  final int repMax;
  final int restSeconds;
  final String reason;

  const PrescribedExercise({
    required this.exerciseId,
    required this.name,
    required this.equipment,
    required this.focus,
    required this.sets,
    required this.repMin,
    required this.repMax,
    required this.restSeconds,
    required this.reason,
  });
}

class ProgramDay {
  final String title;
  final List<PrescribedExercise> exercises;
  const ProgramDay({required this.title, required this.exercises});
}

class GeneratedProgram {
  final ProgramOptions options;
  final List<ProgramDay> days;
  final List<String> priorities;
  final List<String> warnings;
  final Map<String, double> plannedWeeklySets;

  const GeneratedProgram({
    required this.options,
    required this.days,
    required this.priorities,
    required this.warnings,
    required this.plannedWeeklySets,
  });
}

/// Generates a repeatable weekly template. Exercise selection is constrained by
/// the user's exclusions first; scoring only ranks exercises that remain valid.
GeneratedProgram generateProgram({
  required List<Exercise> exercises,
  required List<MuscleLink> links,
  required ProgramOptions options,
  required Map<String, double> recentWeeklySets,
  required Map<String, double> strengthScores,
  required Set<int> exercisesWithHistory,
}) {
  final warnings = <String>[];
  final linksByExercise = <int, List<MuscleLink>>{};
  for (final link in links) {
    (linksByExercise[link.exerciseId] ??= []).add(link);
  }

  final allMuscles = <String>{
    ...muscleNames,
    ...links.map((link) => link.muscle),
  }..removeAll(options.excludedMuscles);

  final available = exercises.where((exercise) {
    if (options.excludedExerciseIds.contains(exercise.id)) return false;
    if (options.equipment.isNotEmpty &&
        !options.equipment.contains(exercise.equipment)) {
      return false;
    }
    final exerciseLinks = linksByExercise[exercise.id] ?? const <MuscleLink>[];
    if (exerciseLinks.isEmpty) return false;
    // An exercise is excluded if it substantially trains a muscle the user
    // explicitly opted out of. Incidental involvement below 20% is tolerated.
    if (exerciseLinks.any(
      (link) =>
          options.excludedMuscles.contains(link.muscle) && link.share >= 0.20,
    )) {
      return false;
    }
    return exerciseLinks.any((link) => allMuscles.contains(link.muscle));
  }).toList();

  if (available.isEmpty) {
    return GeneratedProgram(
      options: options,
      days: const [],
      priorities: const [],
      warnings: const [
        'Не осталось подходящих упражнений. Сними часть ограничений или разреши другое оборудование.',
      ],
      plannedWeeklySets: const {},
    );
  }

  final autoPriorities = <String>[];
  if (options.autoPrioritize &&
      (recentWeeklySets.values.any((value) => value > 0) ||
          strengthScores.isNotEmpty)) {
    final ranked = allMuscles.toList()
      ..sort(
        (a, b) => _weaknessScore(
          b,
          recentWeeklySets,
          strengthScores,
        ).compareTo(_weaknessScore(a, recentWeeklySets, strengthScores)),
      );
    for (final muscle in ranked) {
      if (autoPriorities.length == 2) break;
      if (_weaknessScore(muscle, recentWeeklySets, strengthScores) < 0.35) {
        continue;
      }
      autoPriorities.add(muscle);
    }
  }

  final priorities = <String>{
    ...options.priorityMuscles.where(allMuscles.contains),
    ...autoPriorities.where(
      (muscle) => !options.priorityMuscles.contains(muscle),
    ),
  }.toList();

  // Major groups receive a larger baseline; priority groups receive a modest
  // extra dose rather than an abrupt, potentially unrecoverable jump.
  final targetSets = <String, double>{};
  for (final muscle in allMuscles) {
    final large = _isLargeGroup(muscle);
    var target = options.goal == ProgramGoal.strength
        ? (large ? 8.0 : 5.0)
        : options.goal == ProgramGoal.hypertrophy
        ? (large ? 10.0 : 6.0)
        : (large ? 8.0 : 5.0);
    if (options.level == TrainingLevel.beginner) target *= 0.75;
    if (options.level == TrainingLevel.advanced) target *= 1.15;
    if (priorities.contains(muscle)) target += 2.0;
    targetSets[muscle] = target;
  }

  final setsPerExercise = options.level == TrainingLevel.beginner ? 3 : 3;
  final slotsPerDay = options.sessionMinutes <= 30
      ? 4
      : options.sessionMinutes <= 45
      ? 5
      : options.sessionMinutes <= 60
      ? 6
      : 7;
  final planned = <String, double>{for (final muscle in allMuscles) muscle: 0};
  final dailyExposure = <String, double>{};
  final selectedExerciseCounts = <int, int>{};
  final days = <ProgramDay>[];

  for (var dayIndex = 0; dayIndex < options.daysPerWeek; dayIndex++) {
    final dayExercises = <PrescribedExercise>[];
    final usedToday = <int>{};
    dailyExposure.clear();

    for (var slot = 0; slot < slotsPerDay; slot++) {
      Exercise? bestExercise;
      double bestScore = -1;
      for (final candidate in available) {
        if (usedToday.contains(candidate.id)) continue;
        final candidateLinks =
            linksByExercise[candidate.id] ?? const <MuscleLink>[];
        var score = 0.0;
        for (final link in candidateLinks) {
          if (!allMuscles.contains(link.muscle)) continue;
          final target = targetSets[link.muscle] ?? 0;
          final deficit = math
              .max(0.0, target - (planned[link.muscle] ?? 0))
              .toDouble();
          final daily = dailyExposure[link.muscle] ?? 0;
          final sameDayFactor = daily >= 3
              ? 0.20
              : daily >= 1.5
              ? 0.60
              : 1.0;
          final priorityFactor = priorities.contains(link.muscle) ? 1.45 : 1.0;
          score +=
              deficit * _setCredit(link.share) * sameDayFactor * priorityFactor;
        }

        final isCompound =
            candidateLinks.where((link) => link.share >= 0.15).length >= 2;
        if (options.goal == ProgramGoal.strength && isCompound) score *= 1.12;
        if (exercisesWithHistory.contains(candidate.id)) score *= 1.06;
        // Explicitly preferred exercises receive a modest boost, but the
        // target-muscle deficit and exclusions still take precedence.
        if (options.priorityExerciseIds.contains(candidate.id)) score *= 1.30;
        final repeatCount = selectedExerciseCounts[candidate.id] ?? 0;
        if (repeatCount > 0) score *= 1 / (1 + repeatCount * 0.45);
        // Stable tie-breaker avoids random program changes between generations.
        score += (candidate.id % 17) / 1000;

        if (score > bestScore) {
          bestScore = score;
          bestExercise = candidate;
        }
      }

      if (bestExercise == null) break;
      usedToday.add(bestExercise.id);
      selectedExerciseCounts.update(
        bestExercise.id,
        (count) => count + 1,
        ifAbsent: () => 1,
      );

      final exerciseLinks =
          linksByExercise[bestExercise.id] ?? const <MuscleLink>[];
      final focusLinks =
          exerciseLinks
              .where((link) => allMuscles.contains(link.muscle))
              .toList()
            ..sort((a, b) => b.share.compareTo(a.share));
      if (focusLinks.isEmpty) continue;
      final focus = focusLinks.first.muscle;
      final compound =
          exerciseLinks.where((link) => link.share >= 0.15).length >= 2;
      final (repMin, repMax, rest) = _prescription(options.goal, compound);
      final reason = priorities.contains(focus)
          ? 'Приоритетная группа'
          : (recentWeeklySets[focus] ?? 0) < 4
          ? 'Небольшой объём за последние 6 недель'
          : compound
          ? 'Базовое упражнение с вкладом в несколько групп'
          : 'Добор нагрузки на целевую группу';

      dayExercises.add(
        PrescribedExercise(
          exerciseId: bestExercise.id,
          name: bestExercise.name,
          equipment: bestExercise.equipment,
          focus: focus,
          sets: setsPerExercise,
          repMin: repMin,
          repMax: repMax,
          restSeconds: rest,
          reason: reason,
        ),
      );

      for (final link in exerciseLinks) {
        if (!allMuscles.contains(link.muscle)) continue;
        final credit = setsPerExercise * _setCredit(link.share);
        planned[link.muscle] = (planned[link.muscle] ?? 0) + credit;
        dailyExposure[link.muscle] = (dailyExposure[link.muscle] ?? 0) + credit;
      }
    }

    if (dayExercises.isNotEmpty) {
      // Put demanding multi-joint work for large muscle groups first, then
      // large-group isolation, then smaller groups. This limits pre-fatigue
      // before the lifts that need the most coordination and force.
      int orderRank(PrescribedExercise exercise) {
        final exerciseLinks =
            linksByExercise[exercise.exerciseId] ?? const <MuscleLink>[];
        final compound =
            exerciseLinks.where((link) => link.share >= 0.15).length >= 2;
        final large = _isLargeGroup(exercise.focus);
        if (large && compound) return 0;
        if (large) return 1;
        if (compound) return 2;
        return 3;
      }

      dayExercises.sort((a, b) {
        final rank = orderRank(a).compareTo(orderRank(b));
        if (rank != 0) return rank;
        // Stable ordering for predictable programs.
        return a.exerciseId.compareTo(b.exerciseId);
      });
      days.add(
        ProgramDay(
          title: 'Тренировка ${String.fromCharCode(65 + dayIndex)}',
          exercises: dayExercises,
        ),
      );
    }
  }

  if (days.length < options.daysPerWeek) {
    warnings.add(
      'Для части тренировочных дней не хватило упражнений под выбранные ограничения.',
    );
  }
  if (options.excludedMuscles.isNotEmpty) {
    warnings.add(
      'Исключённые группы не получают целевой нагрузки. Это соответствует выбору, но может ограничить сбалансированное развитие.',
    );
  }
  if (options.sessionMinutes <= 30 && options.daysPerWeek <= 2) {
    warnings.add(
      'При коротких тренировках 2 раза в неделю объём для роста может быть ниже оптимального. Если восстановление позволяет, увеличь время или частоту.',
    );
  }
  if (priorities.isNotEmpty) {
    warnings.add(
      'Приоритеты — эвристическая оценка по объёму последних 6 недель и доступным нормативным оценкам, а не медицинская диагностика слабых мышц.',
    );
  }

  return GeneratedProgram(
    options: options,
    days: days,
    priorities: priorities,
    warnings: warnings,
    plannedWeeklySets: planned,
  );
}

double _weaknessScore(
  String muscle,
  Map<String, double> recentWeeklySets,
  Map<String, double> strengthScores,
) {
  final baseline = _isLargeGroup(muscle) ? 8.0 : 5.0;
  final weekly = recentWeeklySets[muscle] ?? 0;
  final volumeDeficit = (1 - weekly / baseline).clamp(0.0, 1.0).toDouble();
  final strength = strengthScores[muscle];
  if (strength == null) return volumeDeficit;
  final normalizedStrengthDeficit = (1 - strength).clamp(0.0, 1.0).toDouble();
  return volumeDeficit * 0.70 + normalizedStrengthDeficit * 0.30;
}

bool _isLargeGroup(String muscle) => const {
  'Грудь',
  'Широчайшие',
  'Квадрицепс',
  'Ягодицы',
  'Бицепс бедра',
}.contains(muscle);

double _setCredit(double share) {
  if (share >= 0.45) return 1.0;
  if (share >= 0.20) return 0.5;
  if (share >= 0.10) return 0.25;
  return 0.0;
}

(int, int, int) _prescription(ProgramGoal goal, bool compound) {
  return switch (goal) {
    ProgramGoal.strength => compound ? (4, 6, 180) : (6, 10, 120),
    ProgramGoal.hypertrophy => compound ? (6, 10, 180) : (10, 15, 120),
    ProgramGoal.general => compound ? (8, 12, 150) : (10, 15, 90),
  };
}
