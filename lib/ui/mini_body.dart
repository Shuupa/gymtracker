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

    // сначала обычные части, потом подсвеченные мышцы, потом борозды
    for (final pass in [false, true]) {
      for (final sh in bodyShapes) {
        if (sh.view != view || isDetailKind(sh.kind)) continue;
        final hl = sh.kind == BodyKind.muscle && highlight.contains(sh.muscle);
        if (hl != pass) continue;

        final Color fill;
        final Color stroke;
        if (hl) {
          fill = Pal.ice.withValues(alpha: 0.9);
          stroke = Pal.ice;
        } else {
          fill = switch (sh.kind) {
            BodyKind.muscle => const Color(0xFF161E29),
            BodyKind.hair => const Color(0xFF05080C),
            _ => const Color(0xFF0A0E14),
          };
          stroke = const Color(0xFF2E3D52);
        }
        paintBodyShape(
          canvas,
          sh,
          fill: fill,
          stroke: stroke,
          strokeWidth: 1.5 / s,
        );
      }
    }
    for (final sh in bodyShapes) {
      if (sh.view == view && isDetailKind(sh.kind)) {
        paintBodyDetail(canvas, sh, s);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MiniPainter old) =>
      old.highlight != highlight || old.back != back || old.crop != crop;
}
