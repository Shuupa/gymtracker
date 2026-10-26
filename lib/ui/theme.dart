import 'package:flutter/material.dart';

class Pal {
  // Глубокий, насыщенный фон
  static const bg = Color(0xFF04060A);
  static const surface = Color(0xFF0D121A);
  static const surface2 = Color(0xFF18212E);
  static const surface3 = Color(0xFF243244);
  static const line = Color(0xFF2E3D52);

  // Контрастный текст
  static const text = Color(0xFFFFFFFF);
  static const dim = Color(0xFF94A3B8);
  static const dimLight = Color(0xFFCBD5E1);

  // Яркие неоновые акценты
  static const ice = Color(0xFF00E5FF); // Электрический голубой
  static const ember = Color(0xFF818CF8);
  static const cold = Color(0xFF3B82F6);
  static const hot = Color(0xFFFF4D4D);
  static const success = Color(0xFF10B981);
  static const purple = Color(0xFFA855F7); // Неоновый фиолетовый

  static const gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );
  static const gradientSurface = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF18212E), Color(0xFF0D121A)],
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
    primary: Pal.ice,
    onPrimary: Color(0xFF00141A),
    secondary: Pal.purple,
    onSecondary: Pal.text,
    surface: Pal.surface,
    onSurface: Pal.text,
    surfaceContainerHighest: Pal.surface2,
    outline: Pal.line,
    error: Pal.hot,
    onError: Colors.white,
  );

  final radius = BorderRadius.circular(16);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Pal.bg,
    canvasColor: Pal.bg,
    splashColor: Pal.ice.withValues(alpha: 0.1),
    highlightColor: Pal.ice.withValues(alpha: 0.05),
    dividerColor: Pal.line,
    visualDensity: VisualDensity.standard,

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Pal.text,
        fontSize: 36,
        height: 1.1,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
      ),
      headlineLarge: TextStyle(
        color: Pal.text,
        fontSize: 30,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.0,
      ),
      headlineMedium: TextStyle(
        color: Pal.text,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        color: Pal.text,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(
        color: Pal.text,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: TextStyle(
        color: Pal.text,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: Pal.text, fontSize: 16, height: 1.45),
      bodyMedium: TextStyle(color: Pal.dimLight, fontSize: 14, height: 1.45),
      bodySmall: TextStyle(color: Pal.dim, fontSize: 13, height: 1.4),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Pal.bg,
      foregroundColor: Pal.text,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Pal.text,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    ),

    cardTheme: CardThemeData(
      color: Pal.surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Pal.line, width: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Pal.surface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: Pal.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: Pal.ice, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Pal.dim),
      hintStyle: const TextStyle(color: Pal.dim),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Pal.ice,
        foregroundColor: const Color(0xFF00141A),
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Pal.ice,
        minimumSize: const Size(0, 50),
        side: const BorderSide(color: Pal.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Pal.ice,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Pal.surface2,
      selectedColor: Pal.ice.withValues(alpha: 0.2),
      side: const BorderSide(color: Pal.line),
      labelStyle: const TextStyle(
        color: Pal.text,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Pal.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Pal.line),
      ),
      titleTextStyle: const TextStyle(
        color: Pal.text,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      contentTextStyle: const TextStyle(
        color: Pal.dimLight,
        fontSize: 15,
        height: 1.5,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Pal.surface2,
      contentTextStyle: const TextStyle(color: Pal.text, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Pal.line),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Pal.ice,
      linearTrackColor: Pal.line,
    ),
  );
}
