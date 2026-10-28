import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ui/theme.dart';

/// Elo-шар: стеклянная сфера с вращающимся бликом, кольцом прогресса до
/// следующего ранга и числом, которое набегает при появлении.
class EloOrb extends StatefulWidget {
  final int elo;

  /// Прогресс внутри текущего ранга, 0..1.
  final double tierProgress;
  final Color color;
  final double size;

  const EloOrb({
    super.key,
    required this.elo,
    required this.tierProgress,
    required this.color,
    this.size = 216,
  });

  @override
  State<EloOrb> createState() => _EloOrbState();
}

class _EloOrbState extends State<EloOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _spin.stop();
    } else if (!_spin.isAnimating) {
      _spin.repeat();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) => Stack(
          alignment: Alignment.center,
          children: [
            // Тяжёлый слой (кольцо, свечение): перерисовывается только пока
            // идёт вступительная анимация, потом остаётся в кэше.
            RepaintBoundary(
              child: CustomPaint(
                size: Size.square(size),
                painter: _OrbBodyPainter(
                  progress: widget.tierProgress * t,
                  color: widget.color,
                ),
              ),
            ),
            // Лёгкий слой: только вращающийся блик.
            RepaintBoundary(
              child: CustomPaint(
                size: Size.square(size),
                painter: _OrbSheenPainter(spin: _spin),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(widget.elo * t).round()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.25,
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Elo',
                  style: TextStyle(
                    color: Pal.dim,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbBodyPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _OrbBodyPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final s = size.width;
    final ringW = s * 0.06;
    final ringR = s / 2 - ringW;
    final ringRect = Rect.fromCircle(center: c, radius: ringR);
    final orbR = ringR - ringW * 1.1;
    final orbRect = Rect.fromCircle(center: c, radius: orbR);

    // Сфера: свет падает сверху слева.
    canvas.drawCircle(
      c,
      orbR,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 1.0,
          colors: [
            color.withValues(alpha: 0.42),
            color.withValues(alpha: 0.12),
            const Color(0x00000000),
          ],
          stops: const [0, 0.65, 1],
        ).createShader(orbRect),
    );

    // Кромка сферы.
    canvas.drawCircle(
      c,
      orbR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xB3FFFFFF), Color(0x0FFFFFFF), Color(0x66FFFFFF)],
        ).createShader(orbRect),
    );

    // Дорожка кольца.
    canvas.drawCircle(
      c,
      ringR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringW
        ..color = const Color(0x1AFFFFFF),
    );

    final p = progress.clamp(0.0, 1.0);
    if (p > 0.002) {
      final sweep = 2 * math.pi * p;

      // Свечение под дугой.
      canvas.drawArc(
        ringRect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringW * 1.8
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, ringW)
          ..color = color.withValues(alpha: 0.55),
      );

      // Сама дуга: к концу светлеет.
      canvas.drawArc(
        ringRect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringW
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            startAngle: 0,
            endAngle: sweep,
            colors: [
              color.withValues(alpha: 0.55),
              color,
              Color.lerp(color, Colors.white, 0.45)!,
            ],
            transform: const GradientRotation(-math.pi / 2),
          ).createShader(ringRect),
      );

      // Светящаяся точка на конце дуги.
      final angle = -math.pi / 2 + sweep;
      final tip = c + Offset(math.cos(angle), math.sin(angle)) * ringR;
      canvas.drawCircle(tip, ringW * 0.3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_OrbBodyPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// Вращающийся блик вдоль кромки сферы. Одна обводка с градиентом,
/// поэтому перерисовка каждый кадр дешёвая.
class _OrbSheenPainter extends CustomPainter {
  final Animation<double> spin;

  _OrbSheenPainter({required this.spin}) : super(repaint: spin);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final s = size.width;
    final ringW = s * 0.06;
    final orbR = s / 2 - ringW - ringW * 1.1;
    final orbRect = Rect.fromCircle(center: c, radius: orbR);

    canvas.drawCircle(
      c,
      orbR - 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..shader = SweepGradient(
          colors: const [
            Color(0x00FFFFFF),
            Color(0x8CFFFFFF),
            Color(0x00FFFFFF),
            Color(0x00FFFFFF),
          ],
          stops: const [0, 0.1, 0.26, 1],
          transform: GradientRotation(spin.value * 2 * math.pi),
        ).createShader(orbRect),
    );
  }

  @override
  bool shouldRepaint(_OrbSheenPainter oldDelegate) => false;
}
