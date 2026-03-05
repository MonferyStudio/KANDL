import 'package:flutter/material.dart';

/// KANDL app theme - Dark trading terminal with vibrant accents
class AppTheme {
  // === COLORS ===
  // Backgrounds
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color card = Color(0xFF16161F);

  // Borders
  static const Color border = Color(0xFF1E1E2A);
  static const Color borderHighlight = Color(0xFF2A2A3A);

  // Text
  static const Color textPrimary = Color(0xFFE8E8EC);
  static const Color textSecondary = Color(0xFF6B6B7A);
  static const Color textMuted = Color(0xFF6B6B7A);

  // Primary colors
  static const Color green = Color(0xFF00D26A);
  static const Color greenDim = Color(0xFF00A855);
  static const Color red = Color(0xFFFF4757);
  static const Color yellow = Color(0xFFFFA502);
  static const Color blue = Color(0xFF3B82F6);
  static const Color purple = Color(0xFFA855F7);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color orange = Color(0xFFF97316);

  // Semantic aliases
  static const Color positive = green;
  static const Color negative = red;
  static const Color accent = yellow;

  // === TEXT STYLES ===
  static const TextStyle heroNumber = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.bold,
    color: accent,
  );

  static const TextStyle cardLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: textSecondary,
    letterSpacing: 1,
  );

  static const TextStyle cardValue = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: textPrimary,
  );

  static const TextStyle smallText = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );

  static const TextStyle tinyText = TextStyle(
    fontSize: 10,
    color: textMuted,
  );

  // === DECORATIONS ===
  static BoxDecoration cardDecoration = BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: border, width: 1),
  );

  static BoxDecoration accentCardDecoration = BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: accent, width: 1),
  );

  // Metric cards with left border
  static BoxDecoration metricCardDecoration(Color accentColor) {
    return BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(12),
      border: Border(
        left: BorderSide(color: accentColor, width: 4),
        top: BorderSide(color: border, width: 1),
        right: BorderSide(color: border, width: 1),
        bottom: BorderSide(color: border, width: 1),
      ),
    );
  }

  static BoxDecoration buttonDecoration = BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: border, width: 1),
  );

  static BoxDecoration activeButtonDecoration = BoxDecoration(
    color: accent.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: accent, width: 1),
  );

  static BoxDecoration positiveDecoration = BoxDecoration(
    color: positive.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(4),
  );

  static BoxDecoration negativeDecoration = BoxDecoration(
    color: negative.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(4),
  );

  // === THEME DATA ===
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: yellow,
        secondary: blue,
        surface: card,
        error: red,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: heroNumber,
        headlineMedium: cardValue,
        titleLarge: sectionTitle,
        bodyLarge: bodyText,
        bodyMedium: smallText,
        bodySmall: tinyText,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: yellow,
          foregroundColor: background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: yellow,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: yellow),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
      ),
    );
  }

  // === HELPER METHODS ===
  static Color percentColor(double percent) {
    if (percent > 0) return positive;
    if (percent < 0) return negative;
    return textSecondary;
  }

  static TextStyle percentStyle(double percent) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: percentColor(percent),
    );
  }
}
