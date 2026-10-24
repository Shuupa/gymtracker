import 'dart:math' as math;

import 'one_rm.dart';
import 'standards.dart';

typedef MuscleLink = ({
  String muscle,
  int exerciseId,
  String exercise,
  String equipment,
  double share,
});

class MuscleSource {
  final String exercise;
  final double score;
  const MuscleSource(this.exercise, this.score);
}

class MuscleResult {
  final double score; // 0..1
  final List<MuscleSource> sources; // лучшие упражнения для этой мышцы
  const MuscleResult(this.score, this.sources);
}

/// Оценка одного подхода по норме упражнения (0..1).
double setScore(
  Standard std,
  double weight,
  int reps,
  double bodyWeight,
  bool isMale, {
  String exerciseName = '',
  String equipment = '',
}) {
  if (reps <= 0) return 0;
  if (std.repBased) {
    // Rep-based norms are defined by completed repetitions. Do not scale
    // repetitions by weight/body-weight: that makes the score collapse for
    // normal external loads (e.g. 40 kg at 80 kg body weight).
    return std.score(reps.toDouble(), isMale);
  }
  final load = effectiveExerciseLoad(
    exerciseName: exerciseName,
    equipment: equipment,
    bodyWeight: bodyWeight,
    enteredWeight: weight,
  );
  if (bodyWeight <= 0 || load <= 0) return 0;
  final r = reps > maxRepsForEstimate ? maxRepsForEstimate : reps;
  return std.score(oneRm(load, r) / bodyWeight, isMale);
}

/// Сила мышцы = лучшее из упражнений, которые её нагружают.
/// Если мышца в упражнении основная (доля >= 0.5), оценка учитывается
/// полностью, если второстепенная, то со скидкой (до 50%).
Map<String, MuscleResult> muscleScores({
  required Map<int, List<SetData>> sets,
  required List<MuscleLink> links,
  required double bodyWeight,
  required bool isMale,
}) {
  final exScore = <int, double>{};
  final byMuscle = <String, List<MuscleSource>>{};

  for (final l in links) {
    final std = standards[l.exercise];
    final list = sets[l.exerciseId];
    if (std == null || list == null || list.isEmpty) continue;

    final best = exScore.putIfAbsent(l.exerciseId, () {
      var b = 0.0;
      for (final s in list) {
        final v = setScore(
          std,
          s.weight,
          s.reps,
          bodyWeight,
          isMale,
          exerciseName: l.exercise,
          equipment: l.equipment,
        );
        if (v > b) b = v;
      }
      return b;
    });

    final factor = 0.5 + 0.5 * math.min(1.0, l.share / 0.5);
    (byMuscle[l.muscle] ??= []).add(MuscleSource(l.exercise, best * factor));
  }

  final res = <String, MuscleResult>{};
  byMuscle.forEach((muscle, list) {
    list.sort((a, b) => b.score.compareTo(a.score));
    res[muscle] = MuscleResult(list.first.score, list.take(3).toList());
  });
  return res;
}
