import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import 'body_data.dart';

const bodyViewW = 400.0; // два тела по 200 рядом: спереди (0) и сзади (1)
const bodyViewH = 440.0;

const _outline = Color(0xFF9FB6CC);
const _neutralFill = Color(0xFF151C27);
const _emptyMuscle = Color(0xFF232E3D);
const _hairFill = Color(0xFF0B1017);
const _grooveColor = Color(0x70000000);
const _faceColor = Color(0xCCE8EEF5);

/// Что за фигура: часть тела, волосы, мышца, борозда между мышцами,
/// линия лица или глаз.
enum BodyKind { neutral, hair, muscle, groove, face, eye }

class BodyShape {
  final String? muscle; // название мышцы (только для kind == muscle)
  final int view; // 0 = спереди, 1 = сзади
  final Path path;
  final BodyKind kind;
  BodyShape(this.muscle, this.view, this.path, [this.kind = BodyKind.neutral]);

  late final Rect bounds = path.getBounds();
}

/// Все фигуры обоих тел в координатах 400x440 (сзади сдвинуто на x+200).
/// Порядок важен: сначала заливки, потом борозды и черты лица.
final List<BodyShape> bodyShapes = _build();

List<BodyShape> _build() {
  final shapes = <BodyShape>[];

  void addHalf(BodyKind kind, String? muscle, String d, int view) {
    final p = parseSvgPathData(d);
    final ox = view * 200.0;
    shapes.add(BodyShape(muscle, view, p.shift(Offset(ox, 0)), kind));
    final m = Float64List(16)
      ..[0] = -1
      ..[5] = 1
      ..[10] = 1
      ..[12] = 200 + ox
      ..[15] = 1;
    shapes.add(BodyShape(muscle, view, p.transform(m), kind));
  }

  for (var view = 0; view < 2; view++) {
    for (final d in (view == 0 ? neutralFront : neutralBack)) {
      addHalf(BodyKind.neutral, null, d, view);
    }
    for (final d in (view == 0 ? hairFront : hairBack)) {
      addHalf(BodyKind.hair, null, d, view);
    }
    final muscles = view == 0 ? frontMuscles : backMuscles;
    muscles.forEach((name, list) {
      for (final d in list) {
        addHalf(BodyKind.muscle, name, d, view);
      }
    });
    for (final d in (view == 0 ? grooveFront : grooveBack)) {
      addHalf(BodyKind.groove, null, d, view);
    }
    if (view == 0) {
      for (final d in faceLines) {
        addHalf(BodyKind.face, null, d, view);
      }
      for (final d in eyeMarks) {
        addHalf(BodyKind.eye, null, d, view);
      }
    }
  }
  return shapes;
}

/// Рисует одну фигуру: заливка с лёгким объёмом (светлее сверху-слева,
/// темнее снизу-справа) и контур. Используется и картой, и мини-телом.
void paintBodyShape(
  Canvas canvas,
  BodyShape s, {
  required Color fill,
  required Color stroke,
  required double strokeWidth,
  bool shade = true,
}) {
  final paint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;
  if (shade && (s.kind == BodyKind.muscle || s.kind == BodyKind.neutral)) {
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(fill, Colors.white, 0.10)!,
        fill,
        Color.lerp(fill, Colors.black, 0.22)!,
      ],
      stops: const [0.0, 0.45, 1.0],
    ).createShader(s.bounds);
  } else {
    paint.color = fill;
  }
  canvas.drawPath(s.path, paint);
  canvas.drawPath(
    s.path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = stroke
      ..isAntiAlias = true,
  );
}

/// Борозды между мышцами и черты лица (рисуются поверх заливок).
void paintBodyDetail(Canvas canvas, BodyShape s, double scale) {
  switch (s.kind) {
    case BodyKind.groove:
      canvas.drawPath(
        s.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0 / scale
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = _grooveColor
          ..isAntiAlias = true,
      );
    case BodyKind.face:
      canvas.drawPath(
        s.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0 / scale
          ..strokeCap = StrokeCap.round
          ..color = _faceColor
          ..isAntiAlias = true,
      );
    case BodyKind.eye:
      canvas.drawPath(
        s.path,
        Paint()
          ..style = PaintingStyle.fill
          ..color = _faceColor
          ..isAntiAlias = true,
      );
    default:
      break;
  }
}

bool isDetailKind(BodyKind k) =>
    k == BodyKind.groove || k == BodyKind.face || k == BodyKind.eye;

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
                    if (s.kind == BodyKind.muscle && s.path.contains(pt)) {
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
    final scale = size.width / bodyViewW;
    canvas.scale(scale);
    for (final s in bodyShapes) {
      if (isDetailKind(s.kind)) {
        paintBodyDetail(canvas, s, scale);
        continue;
      }
      final fill = switch (s.kind) {
        BodyKind.hair => _hairFill,
        BodyKind.muscle => colors[s.muscle] ?? _emptyMuscle,
        _ => _neutralFill,
      };
      paintBodyShape(canvas, s, fill: fill, stroke: _outline, strokeWidth: 1.3);
    }
  }

  @override
  bool shouldRepaint(_BodyPainter old) => old.colors != colors;
}
