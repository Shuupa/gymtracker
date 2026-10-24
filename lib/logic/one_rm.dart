import 'dart:math' as math;

enum OneRmFormula { epley, brzycki, lombardi, average }

const maxRepsForEstimate = 12;

/// Приблизительная доля массы тела, фактически перемещаемая в упражнении.
/// Значения нужны только для оценки упражнений с собственным весом без введённой нагрузки.
double bodyweightCoefficient(String exerciseName) {
  final n = exerciseName.toLowerCase();
  if (n.contains('планка') || n.contains('вис на турнике')) return 0;
  if (n.contains('отжимания с ногами на возвышении')) return 0.70;
  if (n.contains('отжимания от пола')) return 0.65;
  if (n.contains('отжимания от скамьи')) return 0.55;
  if (n.contains('отжимания на брусьях')) return 0.90;
  if (n.contains('подтягивания')) return 1.00;
  if (n.contains('скандинавские сгибания')) return 0.50;
  if (n.contains('гиперэкстензия')) return 0.50;
  if (n.contains('русские скручивания')) return 0.30;
  if (n.contains('скручивания')) return 0.30;
  if (n.contains('подъём ног лёжа')) return 0.30;
  if (n.contains('подъём ног')) return 0.50;
  if (n.contains('ролик для пресса')) return 0.45;
  if (n.contains('подъём на носки на одной ноге')) return 0.90;
  if (n.contains('приседания без веса')) return 0.65;
  return 1.00;
}

/// Эффективная нагрузка для расчётов.
/// Для bodyweight-упражнения введённый вес (> 0) считается ОБЩЕЙ нагрузкой,
/// как и подписано в поле ввода тренировки. При 0 оцениваем нагрузку по массе тела.
/// Статические упражнения не получают фиктивный 1RM.
double effectiveExerciseLoad({
  required String exerciseName,
  required String equipment,
  required double bodyWeight,
  required double enteredWeight,
}) {
  if (equipment != 'bodyweight') return enteredWeight > 0 ? enteredWeight : 0;
  if (bodyWeight <= 0) return 0;
  final coefficient = bodyweightCoefficient(exerciseName);
  if (coefficient <= 0) return 0;
  if (enteredWeight > 0) return bodyWeight * coefficient + enteredWeight;
  return bodyWeight * coefficient;
}

double oneRm(
  double weight,
  int reps, {
  OneRmFormula formula = OneRmFormula.average,
}) {
  if (weight <= 0 || reps <= 0 || reps > maxRepsForEstimate) return 0;
  if (reps == 1) return weight;
  final epley = weight * (1 + reps / 30);
  final brzycki = weight * 36 / (37 - reps);
  final lombardi = weight * math.pow(reps, 0.10);
  switch (formula) {
    case OneRmFormula.epley:
      return epley;
    case OneRmFormula.brzycki:
      return brzycki;
    case OneRmFormula.lombardi:
      return lombardi;
    case OneRmFormula.average:
      return (epley + brzycki + lombardi) / 3;
  }
}

typedef SetData = ({double weight, int reps});

/// История одного упражнения за одну тренировку (разминка отфильтровывается вызывающим кодом).
class Session {
  final DateTime date;
  final List<SetData> sets;
  Session(this.date, this.sets);

  /// Logged volume (entered weight × reps). For bodyweight exercises where
  /// weight is left at zero this is zero; use [effectiveVolume] when comparing
  /// estimated mechanical work across bodyweight and loaded exercises.
  double get volume =>
      sets.fold(0.0, (sum, set) => sum + set.weight * set.reps);
  double get topWeight => sets.fold(
    0.0,
    (maxWeight, set) => math.max(maxWeight, set.weight).toDouble(),
  );

  double best1rm(
    OneRmFormula formula, {
    double bodyWeight = 80,
    String exerciseName = '',
    String equipment = '',
  }) {
    return sets.fold(0.0, (best, set) {
      final load = effectiveExerciseLoad(
        exerciseName: exerciseName,
        equipment: equipment,
        bodyWeight: bodyWeight,
        enteredWeight: set.weight,
      );
      return math.max(best, oneRm(load, set.reps, formula: formula)).toDouble();
    });
  }

  double effectiveVolume({
    double bodyWeight = 80,
    String exerciseName = '',
    String equipment = '',
  }) {
    return sets.fold(0.0, (sum, set) {
      final load = effectiveExerciseLoad(
        exerciseName: exerciseName,
        equipment: equipment,
        bodyWeight: bodyWeight,
        enteredWeight: set.weight,
      );
      return sum + load * set.reps;
    });
  }
}
