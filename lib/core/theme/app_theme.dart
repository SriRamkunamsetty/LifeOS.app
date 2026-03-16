import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _bg = Color(0xFF090D1A);
  static const _surface = Color(0xFF0F1833);
  static const _neonBlue = Color(0xFF00C2FF);
  static const _electricPurple = Color(0xFF9D4DFF);
  static const _lime = Color(0xFF1DFFCC);

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: _bg,
      colorScheme: const ColorScheme.dark(
        primary: _neonBlue,
        secondary: _electricPurple,
        surface: _surface,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.orbitron(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.orbitron(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.orbitron(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _neonBlue,
        foregroundColor: _bg,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _neonBlue),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: _surface,
        selectedColor: _electricPurple,
      ),
      extensions: const [
        _LifeColors(
          background: _bg,
          surface: _surface,
          accent1: _neonBlue,
          accent2: _electricPurple,
          accent3: _lime,
        ),
      ],
    );
  }
}

@immutable
class _LifeColors extends ThemeExtension<_LifeColors> {
  const _LifeColors({
    required this.background,
    required this.surface,
    required this.accent1,
    required this.accent2,
    required this.accent3,
  });

  final Color background;
  final Color surface;
  final Color accent1;
  final Color accent2;
  final Color accent3;

  @override
  ThemeExtension<_LifeColors> copyWith({
    Color? background,
    Color? surface,
    Color? accent1,
    Color? accent2,
    Color? accent3,
  }) {
    return _LifeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      accent1: accent1 ?? this.accent1,
      accent2: accent2 ?? this.accent2,
      accent3: accent3 ?? this.accent3,
    );
  }

  @override
  ThemeExtension<_LifeColors> lerp(
    covariant ThemeExtension<_LifeColors>? other,
    double t,
  ) {
    if (other is! _LifeColors) return this;
    return _LifeColors(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      accent1: Color.lerp(accent1, other.accent1, t) ?? accent1,
      accent2: Color.lerp(accent2, other.accent2, t) ?? accent2,
      accent3: Color.lerp(accent3, other.accent3, t) ?? accent3,
    );
  }
}
