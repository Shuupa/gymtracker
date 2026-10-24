import 'dart:math' as math;

enum OneRmFormula { epley, brzycki, lombardi, average }

const maxRepsForEstimate = 12; // выше формулы сильно врут

/// Коэффициент доли массы тела, перемещаемой в упражнении.
/// Это приближённые значения для оценки нагрузки, не биомеханическое измерение.
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
  if (n.contains('скручивания')) return 0.30;
  if (n.contains('подъём ног лёжа')) return 0.30;
  if (n.contains('подъём ног')) return 0.50;
  if (n.contains('ролик для пресса')) return 0.45;
  if (n.contains('русские скручивания')) return 0.30;
  if (n.contains('подъём на носки на одной ноге')) return 0.90;
  if (n.contains('приседания без веса')) return 0.65;
  if (n.contains('боковая планка')) return 0;
  // Без специального коэффициента предполагаем, что перемещается всё тело.
  return 1.00;
}

/// Эффективная нагрузка в кг. Для bodyweight введённый вес — это добавочное
/// отягощение, поэтому оно прибавляется к доле собственного веса.
/// Для статических упражнений без корректного 1RM возвращаем 0.
double effectiveExerciseLoad({
  required String exerciseName,
  required String equipment,
  required double bodyWeight,
  required double enteredWeight,
}) {
  if (equipment != 'bodyweight') return enteredWeight;
  final coefficient = bodyweightCoefficient(exerciseName);
  if (coefficient <= 0 || bodyWeight <= 0) return 0;

  // Для упражнений с собственным весом:
  // - 0 кг означает только собственное тело (с коэффициентом упражнения);
  // - небольшой вес трактуем как добавочное отягощение;
  // - значение больше половины массы тела считаем уже введённой общей
  //   нагрузкой. Это предотвращает повторное прибавление веса тела к записи
  //   вроде 113 кг × 6 на брусьях и завышение 1RM до ~251 кг.
  if (enteredWeight <= 0) return bodyWeight * coefficient;
  if (enteredWeight > bodyWeight * 0.5) return enteredWeight;
  return bodyWeight * coefficient + enteredWeight;
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

/// Одна тренировка по конкретному упражнению (без разминки).
class Session {
  final DateTime date;
  final List<SetData> sets;
  Session(this.date, this.sets);

  double get volume => sets.fold(0, (s, e) => s + e.weight * e.reps);
  double get topWeight => sets.fold(0, (m, e) => e.weight > m ? e.weight : m);

  double best1rm(
    OneRmFormula f, {
    double bodyWeight = 80,
    String exerciseName = '',
    String equipment = '',
  }) => sets.fold(0.0, (m, e) {
    final load = effectiveExerciseLoad(
      exerciseName: exerciseName,
      equipment: equipment,
      bodyWeight: bodyWeight,
      enteredWeight: e.weight,
    );
    return math.max(m, oneRm(load, e.reps, formula: f)).toDouble();
  });

  double effectiveVolume({
    double bodyWeight = 80,
    String exerciseName = '',
    String equipment = '',
  }) => sets.fold(0.0, (sum, e) {
    final load = effectiveExerciseLoad(
      exerciseName: exerciseName,
      equipment: equipment,
      bodyWeight: bodyWeight,
      enteredWeight: e.weight,
    );
    return sum + load * e.reps;
  });
}
