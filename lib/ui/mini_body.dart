import 'package:flutter/material.dart';

import 'body_map.dart';
import 'theme.dart';

class MiniBody extends StatelessWidget {
  final Set<String> highlight;
  final bool back;
  final Rect crop;

  const MiniBody({
    super.key,
    required this.highlight,
    required this.back,
    required this.crop,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: crop.width / crop.height,
      child: CustomPaint(painter: _MiniPainter(highlight, back, crop)),
    );
  }
}

class _MiniPainter extends CustomPainter {
  final Set<String> highlight;
  final bool back;
  final Rect crop;
  _MiniPainter(this.highlight, this.back, this.crop);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final s = size.width / crop.width;
    canvas.scale(s);
    final view = back ? 1 : 0;
    canvas.translate(-(crop.left + view * 200.0), -crop.top);

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 / s
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    for (final pass in [false, true]) {
      for (final sh in bodyShapes) {
        if (sh.view != view) continue;
        final hl = sh.muscle != null && highlight.contains(sh.muscle);
        if (hl != pass) continue;

        if (hl) {
          fill.color = Pal.ice.withValues(alpha: 0.9);
          line.color = Pal.ice;
        } else {
          fill.color = sh.muscle == null
              ? const Color(0xFF0A0E14)
              : const Color(0xFF161E29);
          line.color = const Color(0xFF2E3D52);
        }

        canvas.drawPath(sh.path, fill);
        canvas.drawPath(sh.path, line);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MiniPainter old) =>
      old.highlight != highlight || old.back != back || old.crop != crop;
}
