import 'dart:math' as math;

double round1(num value) => (value * 10).round() / 10;

String format1(num value) => round1(value).toStringAsFixed(1);

class GymRank {
  final String title;
  final int minElo;
  final String description;
  final ColorData color;

  const GymRank({
    required this.title,
    required this.minElo,
    required this.description,
    required this.color,
  });
}

/// Простой RGB-контейнер без зависимости от Flutter в logic-слое.
class ColorData {
  final int value; // 0xAARRGGBB
  const ColorData(this.value);
  int get r => (value >> 16) & 0xFF;
  int get g => (value >> 8) & 0xFF;
  int get b => value & 0xFF;
}

/// Elo-пороги: 0 → 200 → 400 → 800 → 1000 → 1200 → 1400 → 1600 → 1800 → 2000 → 2200+
/// Цвета: от светло-голубого к тёмно-фиолетовому неону.
const gymRanks = <GymRank>[
  GymRank(
    title: 'Couch Potato',
    minElo: 0,
    description: 'Начало пути',
    color: ColorData(0xFFB8D4E8), // очень светлый голубой
  ),
  GymRank(
    title: 'String Bean',
    minElo: 200,
    description: 'Первые результаты',
    color: ColorData(0xFF8EC5E8),
  ),
  GymRank(
    title: 'Gym Rat',
    minElo: 400,
    description: 'Тренировки становятся привычкой',
    color: ColorData(0xFF5BA3D9),
  ),
  GymRank(
    title: 'Swole',
    minElo: 800,
    description: 'Сила растёт',
    color: ColorData(0xFF3B82F6),
  ),
  GymRank(
    title: 'Ripped',
    minElo: 1000,
    description: 'Уверенный прогресс',
    color: ColorData(0xFF6366F1),
  ),
  GymRank(
    title: 'Jacked',
    minElo: 1200,
    description: 'Серьёзная подготовка',
    color: ColorData(0xFF8B5CF6),
  ),
  GymRank(
    title: 'Shredded',
    minElo: 1400,
    description: 'Высокий уровень',
    color: ColorData(0xFFA855F7),
  ),
  GymRank(
    title: 'Absolute Unit',
    minElo: 1600,
    description: 'Выдающиеся результаты',
    color: ColorData(0xFFC026D3),
  ),
  GymRank(
    title: 'Gym Boss',
    minElo: 1800,
    description: 'Элита зала',
    color: ColorData(0xFFD946EF),
  ),
  GymRank(
    title: 'Final Boss of This Gym',
    minElo: 2000,
    description: 'Максимальное звание',
    color: ColorData(0xFFE879F9),
  ),
  // 2200+ — тот же ранг, цвет ещё ярче; индекс остаётся последним
];

/// Для отображения «2200+» как отдельного визуального уровня.
const eliteEloThreshold = 2200;

GymRank rankForElo(num elo) {
  final value = elo < 0 ? 0.0 : elo.toDouble();
  return gymRanks.lastWhere(
    (rank) => value >= rank.minElo,
    orElse: () => gymRanks.first,
  );
}

int rankIndexForElo(num elo) {
  final rank = rankForElo(elo);
  return gymRanks.indexOf(rank);
}

/// Обратная совместимость: старый score 0–100 → Elo.
@Deprecated('Use rankForElo')
GymRank rankForScore(num score) => rankForElo(scoreToElo(score));

@Deprecated('Use rankIndexForElo')
int rankIndexForScore(num score) => rankIndexForElo(scoreToElo(score));

/// Перевод старой процентной шкалы 0–100 в Elo (0–2200).
double scoreToElo(num score) =>
    (score.clamp(0, 100).toDouble() / 100.0) * eliteEloThreshold;

/// Сила мышцы 0..1 → вклад в Elo.
double muscleScoreToElo(num score01) =>
    score01.clamp(0, 1).toDouble() * eliteEloThreshold;

/// Общий Elo тела.
///
/// Сила (среднее по мышцам) — 85%, регулярность — 15%.
/// Регулярность: ~30 завершённых тренировок ≈ полный вклад.
double calculateBodyElo({
  required Iterable<num> muscleScores01,
  required int completedWorkouts,
}) {
  final scores = muscleScores01
      .map((s) => s.toDouble().clamp(0.0, 1.0))
      .toList();

  if (scores.isEmpty) return 0;

  final strength01 = scores.reduce((a, b) => a + b) / scores.length;
  final consistency01 = (completedWorkouts / 30.0).clamp(0.0, 1.0);

  final elo = (strength01 * 0.85 + consistency01 * 0.15) * eliteEloThreshold;
  return round1(elo);
}

/// Обратная совместимость со старым API (0–100).
double calculateBodyRating({
  required Iterable<num> muscleScores,
  required int completedWorkouts,
}) {
  // muscleScores здесь исторически 0–100
  final as01 = muscleScores.map((s) => s.toDouble().clamp(0, 100) / 100.0);
  return round1(
    calculateBodyElo(
          muscleScores01: as01,
          completedWorkouts: completedWorkouts,
        ) /
        eliteEloThreshold *
        100,
  );
}

double? calculateBmi({required double? weightKg, required double? heightCm}) {
  if (weightKg == null || heightCm == null || weightKg <= 0 || heightCm <= 0) {
    return null;
  }

  final heightM = heightCm / 100;
  return round1(weightKg / math.pow(heightM, 2));
}
