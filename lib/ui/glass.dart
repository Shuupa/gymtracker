import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'theme.dart';

/// Фон: три мягких цветных пятна за интерфейсом.
class AmbientBackdrop extends StatelessWidget {
  const AmbientBackdrop({super.key});

  // Гауссов спад: края пятен растворяются плавно, кругов не видно.
  static List<Color> _falloff(Color c, double a) => [
    for (var i = 0; i <= 10; i++)
      c.withValues(alpha: a * math.exp(-math.pow(i / 10 * 2.6, 2))),
  ];

  static final _accentGlow = _falloff(Pal.accent, 0.30);
  static final _indigoGlow = _falloff(Pal.indigo, 0.22);
  static final _violetGlow = _falloff(const Color(0xFFBF5AF2), 0.13);

  static Widget _blob(List<Color> colors, double size, double x, double y) {
    return Positioned(
      left: x,
      top: y,
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: RadialGradient(colors: colors)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Фон статичный и лежит в своём слое: он не перерисовывается при
    // прокрутке и не заставляет пересчитывать размытие поверх себя.
    return RepaintBoundary(
      child: IgnorePointer(
        child: ColoredBox(
          color: Pal.bg,
          child: LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              final h = box.maxHeight;
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  _blob(_accentGlow, w * 1.5, w * -0.45, h * -0.18),
                  _blob(_indigoGlow, w * 1.4, w * 0.13, h * 0.32),
                  _blob(_violetGlow, w * 1.3, w * -0.33, h * 0.65),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Базовая стеклянная поверхность: размытие фона, лёгкая заливка и тонкая кромка.
class Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final Color? tint;

  const Glass({
    super.key,
    required this.child,
    this.radius = 24,
    this.blur = 24,
    this.padding,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint ?? Pal.glass,
            borderRadius: shape,
            border: Border.all(color: Pal.glassEdge, width: 0.5),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Нижняя шторка из матового стекла.
class GlassSheet extends StatelessWidget {
  final Widget child;
  const GlassSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xCC1C1C1E),
            border: Border(top: BorderSide(color: Pal.glassEdge, width: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

Future<T?> showGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: const Color(0x73000000),
    builder: (ctx) => GlassSheet(child: builder(ctx)),
  );
}

/// Плавающая кнопка-капсула: акцентное стекло с мягким свечением.
class GlassFab extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final Widget label;

  const GlassFab({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(999);
    // Заливка почти непрозрачная, поэтому размытие под кнопкой не видно.
    // Без BackdropFilter кнопка не пересчитывает размытие при каждой прокрутке.
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: shape,
          boxShadow: [
            BoxShadow(
              color: Pal.accent.withValues(alpha: 0.38),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: shape,
          child: Material(
            color: Pal.accent.withValues(alpha: 0.88),
            child: InkWell(
              onTap: onPressed,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: shape,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                    width: 0.5,
                  ),
                ),
                child: IconTheme(
                  data: const IconThemeData(color: Colors.white, size: 22),
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [icon, const SizedBox(width: 8), label],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Scaffold с общим фоном приложения. Принимает только то, что реально нужно экранам.
class GlassScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const GlassScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const AmbientBackdrop(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: body,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          bottomNavigationBar: bottomNavigationBar,
        ),
      ],
    );
  }
}

/// Liquid glass в духе iOS 26: прозрачная заливка с объёмным бликом,
/// светящаяся кромка (ярче по диагонали) и глубокая мягкая тень.
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;

  const LiquidGlass({
    super.key,
    required this.child,
    this.radius = 30,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    // Размытия здесь нет сознательно: фон за панелью плавный градиент, и блюр
    // его не меняет, а стоит дорого на каждом кадре прокрутки. Весь «стеклянный»
    // вид даёт заливка, блик и кромка.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: const [
          BoxShadow(
            color: Color(0x59000000),
            blurRadius: 44,
            offset: Offset(0, 22),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: Stack(
          children: [
            Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: shape,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x2EFFFFFF),
                    Color(0x0DFFFFFF),
                    Color(0x1CFFFFFF),
                  ],
                  stops: [0, 0.55, 1],
                ),
              ),
              child: child,
            ),
            // Блик и кромка рисуются один раз и кэшируются как отдельный слой.
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _LiquidEdgePainter(radius)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiquidEdgePainter extends CustomPainter {
  final double radius;
  const _LiquidEdgePainter(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final clip = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    canvas.save();
    canvas.clipRRect(clip);

    // Верхний блик: свет стекает сверху вниз.
    canvas.drawRRect(
      clip,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x26FFFFFF), Color(0x00FFFFFF)],
          stops: [0, 0.5],
        ).createShader(rect),
    );

    // Мягкое внутреннее свечение вдоль верхней кромки.
    canvas.drawRRect(
      clip.deflate(3),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9)
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x40FFFFFF), Color(0x00FFFFFF), Color(0x1FFFFFFF)],
          stops: [0, 0.5, 1],
        ).createShader(rect),
    );
    canvas.restore();

    // Яркая тонкая кромка: сильнее в левом верхнем и правом нижнем углах.
    canvas.drawRRect(
      clip.deflate(0.6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xD9FFFFFF),
            Color(0x14FFFFFF),
            Color(0x14FFFFFF),
            Color(0x8CFFFFFF),
          ],
          stops: [0, 0.38, 0.62, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_LiquidEdgePainter oldDelegate) =>
      oldDelegate.radius != radius;
}
