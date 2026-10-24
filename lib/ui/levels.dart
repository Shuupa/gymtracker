import 'package:flutter/material.dart';

import 'theme.dart';

const levelNames = ['Слабый', 'Средний', 'Хороший', 'Отличный', 'Элита'];

const levelColors = [
  Color(0xFF7C9A86), // слабый: серовато-зелёный
  Color(0xFF3FB950), // средний: зелёный
  Color(0xFFFF9F1C), // хороший: оранжевый
  Color(0xFFE5383B), // отличный: красный
  Color(0xFFA855F7), // элита: фиолетовый
];

int levelIndex(double s) =>
    s < 0.4 ? 0 : (s < 0.6 ? 1 : (s < 0.8 ? 2 : (s < 1.0 ? 3 : 4)));

String levelName(double s) => levelNames[levelIndex(s)];
Color levelColor(double s) => levelColors[levelIndex(s)];

class LevelLegend extends StatelessWidget {
  const LevelLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
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
                ),
              ),
              const SizedBox(width: 5),
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
