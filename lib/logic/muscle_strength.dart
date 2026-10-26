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

/// Насколько упражнение должно двигать оценку мышцы.
///
/// Главный движитель (и почти равные со-лидеры) получают полный балл.
/// Раньше балл умножался на сырую долю: грудь в жиме 0.55, широчайшие
/// в тяге 0.40, ягодицы в становой 0.30 — элита становилась «средним»
/// на каждой мышце.
double muscleCredit(double share, double topShare) {
  if (share <= 0 || topShare <= 0) return 0;
  final relative = share / topShare;
  if (relative >= 0.65) return 1.0;
  return 0.0;
}

/// Сила мышцы = лучшее из упражнений, которые её нагружают.
Map<String, MuscleResult> muscleScores({
  required Map<int, List<SetData>> sets,
  required List<MuscleLink> links,
  required double bodyWeight,
  required bool isMale,
}) {
  final topShare = <int, double>{};
  for (final l in links) {
    final cur = topShare[l.exerciseId] ?? 0;
    if (l.share > cur) topShare[l.exerciseId] = l.share;
  }

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

    final credit = muscleCredit(l.share, topShare[l.exerciseId] ?? l.share);
    if (credit <= 0 || best <= 0) continue;
    (byMuscle[l.muscle] ??= []).add(
      MuscleSource(l.exercise, (best * credit).clamp(0.0, 1.0)),
    );
  }

  final res = <String, MuscleResult>{};
  byMuscle.forEach((muscle, list) {
    list.sort((a, b) => b.score.compareTo(a.score));
    res[muscle] = MuscleResult(list.first.score, list.take(3).toList());
  });
  return res;
}
