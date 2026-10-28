import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Дизайн-система: тёмная тема в духе Apple HIG.
/// Чистый чёрный фон, полупрозрачные «стеклянные» поверхности, один акцент (синий),
/// остальные цвета только по смыслу: зелёный = готово, красный = опасно.
class Pal {
  // Фон и поверхности
  static const bg = Color(0xFF000000);
  static const surface = Color(0x1CFFFFFF); // стекло: 11% белого
  static const surface2 = Color(0xFF2C2C2E); // непрозрачная, для полей ввода
  static const surface3 = Color(0xFF3A3A3C);
  static const line = Color(0x26FFFFFF); // разделитель: 15% белого

  // Текст
  static const text = Color(0xFFFFFFFF);
  static const dim = Color(0xFF9A9AA1); // вторичный
  static const dimLight = Color(0xFFD1D1D6);

  // Акцент и смысловые цвета (системные цвета iOS, тёмный режим)
  static const accent = Color(0xFF0A84FF);
  static const indigo = Color(0xFF5E5CE6);
  static const amber = Color(0xFFFF9F0A); // предупреждение
  static const steel = Color(0xFF8E8E93); // нейтральный, разминка
  static const hot = Color(0xFFFF453A); // ошибка, удаление
  static const success = Color(0xFF30D158); // выполнено
  static const onAccent = Color(0xFFFFFFFF);

  // Стекло
  static const glass = Color(0x14FFFFFF); // 8% белого
  static const glassEdge = Color(0x2EFFFFFF); // кромка 18% белого

  // Градиенты оставлены ради совместимости, но плоские: цвет несёт поверхность.
  static const gradientHero = LinearGradient(
    colors: [Color(0xFF1C1C1E), Color(0xFF1C1C1E)],
  );
  static const gradientSurface = LinearGradient(
    colors: [Color(0xFF1C1C1E), Color(0xFF1C1C1E)],
  );
}

/// Градиент силы: светло-голубой → тёмно-фиолетовый.
Color heatColor(double s) {
  final t = s.clamp(0.0, 1.0);
  const stops = [
    Color(0xFFA8D4F0),
    Color(0xFF5BA3D9),
    Color(0xFF6366F1),
    Color(0xFFA855F7),
    Color(0xFF6D28D9),
  ];
  final scaled = t * (stops.length - 1);
  final i = scaled.floor().clamp(0, stops.length - 2);
  final f = scaled - i;
  return Color.lerp(stops[i], stops[i + 1], f)!;
}

ThemeData buildTheme() {
  const scheme = ColorScheme.dark(
    primary: Pal.accent,
    onPrimary: Pal.onAccent,
    secondary: Pal.indigo,
    onSecondary: Pal.onAccent,
    surface: Color(0xFF1C1C1E),
    onSurface: Pal.text,
    surfaceContainerHighest: Pal.surface2,
    outline: Pal.line,
    error: Pal.hot,
    onError: Colors.white,
  );

  // Цифры одной ширины: веса и повторы не «прыгают».
  const figures = [FontFeature.tabularFigures()];
  const pillShape = StadiumBorder();

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Pal.bg,
    canvasColor: Pal.bg,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.white.withValues(alpha: 0.05),
    dividerColor: Pal.line,
    visualDensity: VisualDensity.standard,

    // Переходы как в iOS: сдвиг экрана и жест «назад» от края.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      },
    ),

    // Шкала размеров Apple: 34 / 28 / 22 / 20 / 17 / 15 / 13 / 12 / 11.
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Pal.text,
        fontSize: 34,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        fontFeatures: figures,
      ),
      headlineLarge: TextStyle(
        color: Pal.text,
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        fontFeatures: figures,
      ),
      headlineMedium: TextStyle(
        color: Pal.text,
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        fontFeatures: figures,
      ),
      titleLarge: TextStyle(
        color: Pal.text,
        fontSize: 20,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        fontFeatures: figures,
      ),
      titleMedium: TextStyle(
        color: Pal.text,
        fontSize: 17,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        fontFeatures: figures,
      ),
      titleSmall: TextStyle(
        color: Pal.text,
        fontSize: 15,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        fontFeatures: figures,
      ),
      bodyLarge: TextStyle(
        color: Pal.text,
        fontSize: 17,
        height: 1.35,
        letterSpacing: -0.2,
        fontFeatures: figures,
      ),
      bodyMedium: TextStyle(
        color: Pal.dimLight,
        fontSize: 15,
        height: 1.35,
        letterSpacing: -0.1,
        fontFeatures: figures,
      ),
      bodySmall: TextStyle(
        color: Pal.dim,
        fontSize: 13,
        height: 1.3,
        fontFeatures: figures,
      ),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),

    // Прозрачная шапка, как «scroll edge» в iOS: без линий и тени.
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Pal.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: 64,
      titleSpacing: 20,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: const TextStyle(
        color: Pal.text,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (_) =>
          const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
    ),

    cardTheme: CardThemeData(
      color: Pal.surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Pal.line, width: 0.5),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Pal.surface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Pal.accent, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Pal.dim),
      hintStyle: const TextStyle(color: Pal.dim),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Pal.accent,
      selectionColor: Color(0x550A84FF),
      selectionHandleColor: Pal.accent,
    ),

    // Кнопки-капсулы, как в iOS 26.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Pal.accent,
        foregroundColor: Pal.onAccent,
        disabledBackgroundColor: Pal.surface2,
        disabledForegroundColor: Pal.dim,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        shape: pillShape,
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Pal.text,
        backgroundColor: Pal.glass,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        side: const BorderSide(color: Pal.glassEdge, width: 0.5),
        shape: pillShape,
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Pal.accent,
        shape: pillShape,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: Pal.text),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Pal.accent
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Pal.onAccent : Pal.dimLight,
        ),
        side: const WidgetStatePropertyAll(
          BorderSide(color: Pal.glassEdge, width: 0.5),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Pal.glass,
      selectedColor: Pal.accent.withValues(alpha: 0.28),
      checkmarkColor: Pal.accent,
      side: const BorderSide(color: Pal.glassEdge, width: 0.5),
      labelStyle: const TextStyle(
        color: Pal.text,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      shape: pillShape,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Pal.success : Pal.surface3,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF2C2C2E),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: const TextStyle(
        color: Pal.text,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: Pal.dimLight,
        fontSize: 15,
        height: 1.4,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xF22C2C2E),
      contentTextStyle: const TextStyle(color: Pal.text, fontSize: 15),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Pal.glassEdge, width: 0.5),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Pal.accent,
      linearTrackColor: Pal.surface3,
    ),
    dividerTheme: const DividerThemeData(color: Pal.line, thickness: 0.5),
  );
}
