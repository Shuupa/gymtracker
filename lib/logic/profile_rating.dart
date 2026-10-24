import 'dart:math' as math;

double round1(num value) => (value * 10).round() / 10;

String format1(num value) => round1(value).toStringAsFixed(1);

class GymRank {
  final String title;
  final int minScore;
  final String description;

  const GymRank({
    required this.title,
    required this.minScore,
    required this.description,
  });
}

const gymRanks = <GymRank>[
  GymRank(title: 'Couch Potato', minScore: 0, description: 'Начало пути'),
  GymRank(title: 'String Bean', minScore: 10, description: 'Первые результаты'),
  GymRank(
    title: 'Gym Rat',
    minScore: 20,
    description: 'Тренировки становятся привычкой',
  ),
  GymRank(title: 'Swole', minScore: 30, description: 'Сила растёт'),
  GymRank(title: 'Ripped', minScore: 40, description: 'Уверенный прогресс'),
  GymRank(title: 'Jacked', minScore: 50, description: 'Серьёзная подготовка'),
  GymRank(title: 'Shredded', minScore: 60, description: 'Высокий уровень'),
  GymRank(
    title: 'Absolute Unit',
    minScore: 70,
    description: 'Выдающиеся результаты',
  ),
  GymRank(title: 'Gym Boss', minScore: 80, description: 'Элита зала'),
  GymRank(
    title: 'Final Boss of This Gym',
    minScore: 90,
    description: 'Максимальное звание',
  ),
];

GymRank rankForScore(num score) {
  final value = score.clamp(0, 100).toDouble();

  return gymRanks.lastWhere(
    (rank) => value >= rank.minScore,
    orElse: () => gymRanks.first,
  );
}

int rankIndexForScore(num score) {
  final rank = rankForScore(score);
  return gymRanks.indexOf(rank);
}

/// Общая оценка всего тела на основе существующих оценок мышц.
///
/// muscleScores должны быть результатами уже имеющейся в приложении
/// функции muscleScores(), а не отдельной новой системой оценки.
///
/// Важно: score должен иметь диапазон 0–100.
double calculateBodyRating({
  required Iterable<num> muscleScores,
  required int completedWorkouts,
}) {
  final scores = muscleScores
      .map((score) => score.toDouble().clamp(0, 100))
      .toList();

  if (scores.isEmpty) return 0;

  // Средняя оценка по всем доступным мышечным группам.
  final strengthScore = scores.reduce((a, b) => a + b) / scores.length;

  // Регулярность влияет на рейтинг умеренно, чтобы сила оставалась
  // главным фактором, а не количество записей в приложении.
  final consistencyScore = (completedWorkouts / 30 * 100)
      .clamp(0, 100)
      .toDouble();

  return round1(strengthScore * 0.85 + consistencyScore * 0.15)
      .clamp(0, 100)
      .toDouble();
}

double? calculateBmi({required double? weightKg, required double? heightCm}) {
  if (weightKg == null || heightCm == null || weightKg <= 0 || heightCm <= 0) {
    return null;
  }

  final heightM = heightCm / 100;
  return round1(weightKg / math.pow(heightM, 2));
}
