import 'package:flutter/material.dart';

import 'theme.dart';

const levelNames = ['Слабый', 'Средний', 'Хороший', 'Отличный', 'Элита'];

/// Градиент развитости: светло-голубой → тёмно-фиолетовый.
const levelColors = [
  Color(0xFF7EB8D4), // слабый: светлый голубой
  Color(0xFF5B9FDB), // средний
  Color(0xFF7B6CF0), // хороший: сине-фиолетовый
  Color(0xFFA855F7), // отличный: фиолетовый
  Color(0xFF7C3AED), // элита: тёмно-фиолетовый неон
];

int levelIndex(double s) =>
    s < 0.4 ? 0 : (s < 0.6 ? 1 : (s < 0.8 ? 2 : (s < 1.0 ? 3 : 4)));

String levelName(double s) => levelNames[levelIndex(s)];
Color levelColor(double s) => levelColors[levelIndex(s)];

/// Плавный цвет по силе 0..1 (для карты мышц и прогресс-баров).
Color muscleGradientColor(double s) {
  final t = s.clamp(0.0, 1.0);
  const stops = [
    Color(0xFFA8D4F0), // почти белый голубой
    Color(0xFF5BA3D9),
    Color(0xFF6366F1),
    Color(0xFFA855F7),
    Color(0xFF6D28D9), // тёмно-фиолетовый
  ];
  final scaled = t * (stops.length - 1);
  final i = scaled.floor().clamp(0, stops.length - 2);
  final f = scaled - i;
  return Color.lerp(stops[i], stops[i + 1], f)!;
}

class LevelLegend extends StatelessWidget {
  const LevelLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < levelNames.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: levelColors[i],
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: levelColors[i].withValues(alpha: 0.45),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                levelNames[i],
                style: const TextStyle(color: Pal.dim, fontSize: 12),
              ),
            ],
          ),
      ],
    );
  }
}
