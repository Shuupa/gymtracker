import 'package:flutter/material.dart';

class MuscleGroup {
  final String name;
  final List<String> muscles;
  final bool back;
  final Rect crop;

  const MuscleGroup({
    required this.name,
    required this.muscles,
    required this.back,
    required this.crop,
  });
}

/// Основная категория упражнения — категория с наибольшей
/// суммарной долей участия мышц.
MuscleGroup? primaryMuscleGroup(Map<String, double> shares) {
  if (shares.isEmpty || muscleGroups.isEmpty) {
    return null;
  }

  MuscleGroup? bestGroup;
  var bestShare = -1.0;

  for (final group in muscleGroups) {
    final share = groupShare(group, shares);

    if (share > bestShare) {
      bestShare = share;
      bestGroup = group;
    }
  }

  return bestGroup;
}

/// Порог попадания упражнения в категорию.
/// 5% — чтобы не показывать упражнения, где мышца задействована
/// совсем незначительно.
const double groupMinShare = 0.05;

/// Доля всех мышц выбранной категории в упражнении.
double groupShare(MuscleGroup group, Map<String, double> shares) {
  return group.muscles.fold<double>(
    0,
    (sum, muscle) => sum + (shares[muscle] ?? 0),
  );
}

/// Координаты областей относительно одной фигуры размером 200 × 440.
/// Эти области используются MiniBody для отображения мышц на плитках.
final List<MuscleGroup> muscleGroups = [
  MuscleGroup(
    name: 'Грудь',
    muscles: ['Грудь'],
    back: false,
    crop: const Rect.fromLTWH(24, 76, 152, 78),
  ),
  MuscleGroup(
    name: 'Спина',
    muscles: ['Широчайшие', 'Трапеции', 'Разгибатели спины'],
    back: true,
    crop: const Rect.fromLTWH(24, 66, 152, 145),
  ),
  MuscleGroup(
    name: 'Плечи',
    muscles: ['Передние дельты', 'Средние дельты', 'Задние дельты'],
    back: false,
    crop: const Rect.fromLTWH(24, 68, 152, 76),
  ),
  MuscleGroup(
    name: 'Бицепс',
    muscles: ['Бицепс'],
    back: false,
    crop: const Rect.fromLTWH(24, 112, 152, 80),
  ),
  MuscleGroup(
    name: 'Трицепс',
    muscles: ['Трицепс'],
    back: true,
    crop: const Rect.fromLTWH(24, 112, 152, 80),
  ),
  MuscleGroup(
    name: 'Предплечья',
    muscles: ['Предплечья'],
    back: false,
    crop: const Rect.fromLTWH(24, 150, 152, 95),
  ),
  MuscleGroup(
    name: 'Пресс',
    muscles: ['Пресс'],
    back: false,
    crop: const Rect.fromLTWH(35, 125, 130, 100),
  ),
  MuscleGroup(
    name: 'Квадрицепс',
    muscles: ['Квадрицепс'],
    back: false,
    crop: const Rect.fromLTWH(35, 205, 130, 125),
  ),
  MuscleGroup(
    name: 'Бицепс бедра',
    muscles: ['Бицепс бедра'],
    back: true,
    crop: const Rect.fromLTWH(35, 205, 130, 125),
  ),
  MuscleGroup(
    name: 'Ягодицы',
    muscles: ['Ягодицы'],
    back: true,
    crop: const Rect.fromLTWH(30, 190, 140, 85),
  ),
  MuscleGroup(
    name: 'Икры',
    muscles: ['Икры'],
    back: false,
    crop: const Rect.fromLTWH(35, 315, 130, 105),
  ),
];
