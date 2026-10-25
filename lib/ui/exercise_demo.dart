import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'exercise_demo_data.dart';
import 'theme.dart';

const _bg = Color(0xFF0E141C);
const _figure = Color(0xFFE2EEFA);
const _torso = Color(0xFF96ACC6);
const _far = Color(0xFF607490);
const _eq = Color(0xFF78889E);
const _eq2 = Color(0xFF4E5C70);
const _floor = Color(0xFF34425A);

/// Анимированная схема выполнения упражнения: фигурка плавно движется между
/// начальной и конечной позой, рядом оборудование, работающая зона подсвечена.
class ExerciseDemo extends StatefulWidget {
  final String name;
  final double height;
  const ExerciseDemo({super.key, required this.name, this.height = 190});

  @override
  State<ExerciseDemo> createState() => _ExerciseDemoState();
}

class _ExerciseDemoState extends State<ExerciseDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = demoData[widget.name];
    if (data == null) return const SizedBox.shrink();
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Pal.line),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: RepaintBoundary(
          child: CustomPaint(painter: _DemoPainter(data, _c)),
        ),
      ),
    );
  }
}

class _DemoPainter extends CustomPainter {
  final DemoData d;
  final Animation<double> anim;
  _DemoPainter(this.d, this.anim) : super(repaint: anim);

  static const _g = 100.0; // уровень пола

  Color _tone(int t) => switch (t) {
    1 => Pal.ember,
    2 => _eq2,
    3 => _figure,
    _ => _eq,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final box = d.box;
    final x0 = box[0], y0 = box[1], x1 = box[2];
    final y1 = math.max(box[3], _g + 4);
    final sc = math.min(size.width / (x1 - x0), size.height / (y1 - y0));
    final ox = (size.width - (x1 - x0) * sc) / 2 - x0 * sc;
    final oy = (size.height - (y1 - y0) * sc) / 2 - y0 * sc;
    Offset t(double x, double y) => Offset(x * sc + ox, y * sc + oy);

    // время: туда-обратно с короткими паузами в крайних позах
    final p = anim.value;
    var u = p < 0.5 ? p * 2 : (1 - p) * 2;
    u = Curves.easeInOut.transform(((u - 0.12) / 0.76).clamp(0.0, 1.0));
    final n = d.frames.length;
    final fp = u * (n - 1);
    final i = fp.floor().clamp(0, n - 2);
    final f = fp - i;
    final a = d.frames[i], b = d.frames[i + 1];
    final pts = List<Offset>.generate(17, (k) {
      final x = (a[2 * k] + (b[2 * k] - a[2 * k]) * f) / 4;
      final y = (a[2 * k + 1] + (b[2 * k + 1] - a[2 * k + 1]) * f) / 4;
      // дальние конечности чуть смещены назад, чтобы читалась глубина
      final back = (k >= 9 && k <= 14) ? -2.5 : 0.0;
      return t(x + back, y);
    });

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    void seg(Offset p1, Offset p2, double w, Color c) {
      paint
        ..color = c
        ..strokeWidth = math.max(1.0, w * sc);
      canvas.drawLine(p1, p2, paint);
    }

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    void disc(Offset c, double r, Color col) {
      fill.color = col;
      canvas.drawCircle(c, r * sc, fill);
    }

    // пол
    final fy = t(0, _g).dy;
    seg(Offset(0, fy), Offset(size.width, fy), 0.8, _floor);

    // статичное оборудование
    for (final pr in d.props) {
      final v = pr.n;
      switch (pr.k) {
        case 0:
          fill.color = _tone(pr.tone);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromPoints(t(v[0], v[1]), t(v[2], v[3])),
              Radius.circular(3 * sc),
            ),
            fill,
          );
        case 1:
          seg(t(v[0], v[1]), t(v[2], v[3]), v[4], _tone(pr.tone));
        case 2:
          disc(t(v[0], v[1]), v[2], _tone(pr.tone));
        case 3:
          final path = Path()..moveTo(t(v[0], v[1]).dx, t(v[0], v[1]).dy);
          for (var q = 2; q + 1 < v.length; q += 2) {
            final o = t(v[q], v[q + 1]);
            path.lineTo(o.dx, o.dy);
          }
          fill.color = _tone(pr.tone);
          canvas.drawPath(path..close(), fill);
        default:
          break;
      }
    }
    // тросы и рычаги под фигурой
    for (final pr in d.props) {
      if (pr.k == 5 || pr.k == 6) {
        final end = pts[pr.n[2].toInt() == 0 ? 15 : 16];
        seg(
          t(pr.n[0], pr.n[1]),
          end,
          pr.k == 5 ? 1.2 : 3.5,
          pr.k == 5 ? _eq : _eq2,
        );
      }
    }

    // дальние конечности
    seg(pts[2], pts[9], 8, _far);
    seg(pts[9], pts[10], 6.5, _far);
    seg(pts[10], pts[11], 4.5, _far);
    seg(pts[1], pts[12], 6, _far);
    seg(pts[12], pts[13], 5, _far);
    seg(pts[13], pts[14], 4, _far);
    // туловище и ближняя нога
    seg(pts[2], pts[1], 14, _torso);
    seg(pts[2], pts[3], 8.5, _figure);
    seg(pts[3], pts[4], 7, _figure);
    seg(pts[4], pts[5], 4.5, _figure);
    // голова и ближняя рука
    disc(pts[0], 7.8, _figure);
    seg(pts[1], pts[6], 6.5, _figure);
    seg(pts[6], pts[7], 5.5, _figure);
    seg(pts[7], pts[8], 4.2, _figure);

    // подсветка работающей зоны
    final glow = Pal.ember.withValues(alpha: 0.58);
    for (final fo in d.focus) {
      if (fo[0] == 0) {
        final pa = pts[fo[1].toInt()], pb = pts[fo[2].toInt()];
        final q0 = Offset.lerp(pa, pb, fo[3])!,
            q1 = Offset.lerp(pa, pb, fo[4])!;
        seg(q0, q1, fo[5], glow);
      } else {
        disc(pts[fo[1].toInt()], fo[2], glow);
      }
    }

    // подвижные предметы
    for (final pr in d.props) {
      final v = pr.n;
      if (pr.k == 4) {
        final c = pts[v[0].toInt() == 0 ? 15 : 16];
        disc(c, v[1], _tone(pr.tone));
        disc(c, v[1] * 0.28, _bg);
      } else if (pr.k == 7) {
        final c = pts[v[0].toInt() == 0 ? 15 : 16];
        final th = v[1] * math.pi / 180;
        final dx = math.sin(th) * v[2] * sc, dy = math.cos(th) * v[2] * sc;
        seg(c.translate(-dx, -dy), c.translate(dx, dy), v[3], _tone(pr.tone));
      } else if (pr.k == 8) {
        final c = pts[v[0].toInt() == 0 ? 15 : 16];
        paint
          ..color = Pal.ember
          ..strokeWidth = 3 * sc;
        canvas.drawCircle(c, v[1] * sc, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DemoPainter old) => old.d != d;
}
