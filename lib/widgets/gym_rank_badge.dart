import 'package:flutter/material.dart';

import 'dart:math' as math;

import '../logic/profile_rating.dart';

class GymRankBadge extends StatelessWidget {
  final int rankIndex;
  final double size;

  const GymRankBadge({super.key, required this.rankIndex, this.size = 112});

  @override
  Widget build(BuildContext context) {
    final index = rankIndex.clamp(0, gymRanks.length - 1);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GymRankPainter(rankIndex: index)),
    );
  }
}

class _GymRankPainter extends CustomPainter {
  final int rankIndex;

  const _GymRankPainter({required this.rankIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.43;

    // светло-голубой → тёмно-фиолетовый неон
    final accent = Color.lerp(
      const Color(0xFFA8D4F0),
      const Color(0xFF7C3AED),
      (rankIndex / 9).clamp(0.0, 1.0),
    )!;

    final backgroundPaint = Paint()
      ..color = const Color(0xFF171D25)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = accent
      ..strokeWidth = size.width * 0.025
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawCircle(center, radius, borderPaint);

    // Число звания задаёт количество лучей эмблемы.
    final points = 3 + rankIndex;
    final innerRadius = radius * (0.35 + rankIndex * 0.012);
    final outerRadius = radius * 0.77;
    final path = Path();

    for (var i = 0; i < points * 2; i++) {
      final angle = -math.pi / 2 + i * math.pi / points;
      final r = i.isEven ? outerRadius : innerRadius;

      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = accent.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = accent
        ..strokeWidth = size.width * 0.018
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    // Центральный символ меняется вместе со званием.
    final icon = rankIndex < 2
        ? Icons.bedtime_outlined
        : rankIndex < 4
        ? Icons.fitness_center
        : rankIndex < 7
        ? Icons.bolt
        : rankIndex < 9
        ? Icons.workspace_premium
        : Icons.emoji_events;

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size.width * 0.28,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: accent,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    iconPainter.paint(
      canvas,
      Offset(
        center.dx - iconPainter.width / 2,
        center.dy - iconPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _GymRankPainter oldDelegate) {
    return oldDelegate.rankIndex != rankIndex;
  }
}
