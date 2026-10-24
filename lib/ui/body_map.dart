import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import 'body_data.dart';

const bodyViewW = 400.0; // два тела по 200 рядом: спереди (0) и сзади (1)
const bodyViewH = 440.0;

const _outline = Color(0xFF9FB6CC);
const _neutralFill = Color(0xFF151C27);
const _emptyMuscle = Color(0xFF232E3D);

class BodyShape {
  final String? muscle; // null = нейтральная часть тела
  final int view; // 0 = спереди, 1 = сзади
  final Path path;
  BodyShape(this.muscle, this.view, this.path);
}

/// Все фигуры обоих тел в координатах 400x440 (сзади сдвинуто на x+200).
final List<BodyShape> bodyShapes = _build();

List<BodyShape> _build() {
  final shapes = <BodyShape>[];

  void addHalf(String? muscle, String d, int view) {
    final p = parseSvgPathData(d);
    final ox = view * 200.0;
    shapes.add(BodyShape(muscle, view, p.shift(Offset(ox, 0))));
    final m = Float64List(16)
      ..[0] = -1
      ..[5] = 1
      ..[10] = 1
      ..[12] = 200 + ox
      ..[15] = 1;
    shapes.add(BodyShape(muscle, view, p.transform(m)));
  }

  for (var view = 0; view < 2; view++) {
    shapes.add(
      BodyShape(
        null,
        view,
        Path()..addOval(
          Rect.fromCenter(
            center: Offset(100.0 + view * 200, 31),
            width: 40,
            height: 54,
          ),
        ),
      ),
    );
    for (final d in (view == 0 ? neutralFront : neutralBack)) {
      addHalf(null, d, view);
    }
  }
  frontMuscles.forEach((name, list) {
    for (final d in list) {
      addHalf(name, d, 0);
    }
  });
  backMuscles.forEach((name, list) {
    for (final d in list) {
      addHalf(name, d, 1);
    }
  });
  return shapes;
}

class BodyMap extends StatelessWidget {
  /// Цвет по названию мышцы. Нет в карте = нейтральный серый.
  final Map<String, Color> colors;
  final ValueChanged<String>? onMuscleTap;

  const BodyMap({super.key, required this.colors, this.onMuscleTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (final t in ['Спереди', 'Сзади'])
              Expanded(
                child: Center(
                  child: Text(t, style: Theme.of(context).textTheme.bodySmall),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        AspectRatio(
          aspectRatio: bodyViewW / bodyViewH,
          child: LayoutBuilder(
            builder: (_, c) {
              final scale = c.maxWidth / bodyViewW;
              return GestureDetector(
                onTapUp: (d) {
                  final pt = d.localPosition / scale;
                  for (final s in bodyShapes.reversed) {
                    if (s.muscle != null && s.path.contains(pt)) {
                      onMuscleTap?.call(s.muscle!);
                      return;
                    }
                  }
                },
                child: CustomPaint(
                  size: Size(c.maxWidth, c.maxHeight),
                  painter: _BodyPainter(colors),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BodyPainter extends CustomPainter {
  final Map<String, Color> colors;
  _BodyPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / bodyViewW);
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = _outline
      ..isAntiAlias = true;
    for (final s in bodyShapes) {
      fill.color = s.muscle == null
          ? _neutralFill
          : (colors[s.muscle] ?? _emptyMuscle);
      canvas.drawPath(s.path, fill);
      canvas.drawPath(s.path, line);
    }
  }

  @override
  bool shouldRepaint(_BodyPainter old) => old.colors != colors;
}
