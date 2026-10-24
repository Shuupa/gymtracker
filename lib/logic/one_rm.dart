import 'dart:math' as math;

enum OneRmFormula { epley, brzycki, lombardi, average }

const maxRepsForEstimate = 12; // выше формулы сильно врут

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

  double best1rm(OneRmFormula f) =>
      sets.fold(0, (m, e) => math.max(m, oneRm(e.weight, e.reps, formula: f)));
}
