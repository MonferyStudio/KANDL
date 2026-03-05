import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

/// Extension to easily access theme from context
extension ThemeContext on BuildContext {
  /// Get theme without listening (for callbacks)
  AppThemeData get theme => read<SettingsService>().currentTheme;

  /// Watch theme changes (for build methods)
  AppThemeData get watchTheme => watch<SettingsService>().currentTheme;
}

/// Theme data structure
class AppThemeData {
  final String id;
  final String name;
  final String icon;
  final bool isDark;

  // Core colors
  final Color background;
  final Color surface;
  final Color card;
  final Color border;
  final Color borderHighlight;

  // Text colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // Accent colors
  final Color primary;
  final Color secondary;
  final Color accent;

  // Semantic colors
  final Color positive;
  final Color negative;

  // Additional accents
  final Color cyan;
  final Color orange;
  final Color purple;
  final Color yellow;
  final Color blue;

  const AppThemeData({
    required this.id,
    required this.name,
    required this.icon,
    required this.isDark,
    required this.background,
    required this.surface,
    required this.card,
    required this.border,
    required this.borderHighlight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.positive,
    required this.negative,
    required this.cyan,
    required this.orange,
    required this.purple,
    required this.yellow,
    required this.blue,
  });

  /// Convert to Flutter ThemeData
  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primary,
        secondary: secondary,
        surface: card,
        error: negative,
        onPrimary: isDark ? background : textPrimary,
        onSecondary: isDark ? background : textPrimary,
        onSurface: textPrimary,
        onError: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDark ? background : textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
      ),
    );
  }
}

/// All available themes
class AppThemes {
  static const Map<String, AppThemeData> themes = {
    // === DARK THEMES ===
    'dark_cyan': AppThemeData(
      id: 'dark_cyan',
      name: 'Cyber Terminal',
      icon: '🌊',
      isDark: true,
      background: Color(0xFF0A0A0F),
      surface: Color(0xFF12121A),
      card: Color(0xFF16161F),
      border: Color(0xFF1E1E2A),
      borderHighlight: Color(0xFF2A2A3A),
      textPrimary: Color(0xFFE8E8EC),
      textSecondary: Color(0xFF6B6B7A),
      textMuted: Color(0xFF6B6B7A),
      primary: Color(0xFF06B6D4),
      secondary: Color(0xFF3B82F6),
      accent: Color(0xFFFFA502),
      positive: Color(0xFF00D26A),
      negative: Color(0xFFFF4757),
      cyan: Color(0xFF06B6D4),
      orange: Color(0xFFF97316),
      purple: Color(0xFFA855F7),
      yellow: Color(0xFFFFA502),
      blue: Color(0xFF3B82F6),
    ),

    'dark_red': AppThemeData(
      id: 'dark_red',
      name: 'Blood Market',
      icon: '🔴',
      isDark: true,
      background: Color(0xFF0F0A0A),
      surface: Color(0xFF1A1212),
      card: Color(0xFF1F1616),
      border: Color(0xFF2A1E1E),
      borderHighlight: Color(0xFF3A2A2A),
      textPrimary: Color(0xFFECE8E8),
      textSecondary: Color(0xFF7A6B6B),
      textMuted: Color(0xFF7A6B6B),
      primary: Color(0xFFEF4444),
      secondary: Color(0xFFF97316),
      accent: Color(0xFFEAB308),
      positive: Color(0xFF22C55E),
      negative: Color(0xFFEF4444),
      cyan: Color(0xFFF97316),
      orange: Color(0xFFF97316),
      purple: Color(0xFFEC4899),
      yellow: Color(0xFFEAB308),
      blue: Color(0xFFF43F5E),
    ),

    'dark_green': AppThemeData(
      id: 'dark_green',
      name: 'Matrix',
      icon: '🟢',
      isDark: true,
      background: Color(0xFF0A0F0A),
      surface: Color(0xFF121A12),
      card: Color(0xFF161F16),
      border: Color(0xFF1E2A1E),
      borderHighlight: Color(0xFF2A3A2A),
      textPrimary: Color(0xFFE8ECE8),
      textSecondary: Color(0xFF6B7A6B),
      textMuted: Color(0xFF6B7A6B),
      primary: Color(0xFF22C55E),
      secondary: Color(0xFF10B981),
      accent: Color(0xFF84CC16),
      positive: Color(0xFF22C55E),
      negative: Color(0xFFEF4444),
      cyan: Color(0xFF14B8A6),
      orange: Color(0xFF84CC16),
      purple: Color(0xFF8B5CF6),
      yellow: Color(0xFFA3E635),
      blue: Color(0xFF10B981),
    ),

    'dark_purple': AppThemeData(
      id: 'dark_purple',
      name: 'Neon Nights',
      icon: '🟣',
      isDark: true,
      background: Color(0xFF0D0A0F),
      surface: Color(0xFF15121A),
      card: Color(0xFF1A161F),
      border: Color(0xFF241E2A),
      borderHighlight: Color(0xFF342A3A),
      textPrimary: Color(0xFFEAE8EC),
      textSecondary: Color(0xFF756B7A),
      textMuted: Color(0xFF756B7A),
      primary: Color(0xFFA855F7),
      secondary: Color(0xFFEC4899),
      accent: Color(0xFFF472B6),
      positive: Color(0xFF22C55E),
      negative: Color(0xFFEF4444),
      cyan: Color(0xFFE879F9),
      orange: Color(0xFFF472B6),
      purple: Color(0xFFA855F7),
      yellow: Color(0xFFFBBF24),
      blue: Color(0xFF8B5CF6),
    ),

    // === LIGHT THEMES ===
    'light_blue': AppThemeData(
      id: 'light_blue',
      name: 'Ocean Breeze',
      icon: '☀️',
      isDark: false,
      background: Color(0xFFF8FAFC),
      surface: Color(0xFFFFFFFF),
      card: Color(0xFFFFFFFF),
      border: Color(0xFFE2E8F0),
      borderHighlight: Color(0xFFCBD5E1),
      textPrimary: Color(0xFF1E293B),
      textSecondary: Color(0xFF64748B),
      textMuted: Color(0xFF94A3B8),
      primary: Color(0xFF0EA5E9),
      secondary: Color(0xFF3B82F6),
      accent: Color(0xFFF59E0B),
      positive: Color(0xFF10B981),
      negative: Color(0xFFEF4444),
      cyan: Color(0xFF06B6D4),
      orange: Color(0xFFF97316),
      purple: Color(0xFF8B5CF6),
      yellow: Color(0xFFF59E0B),
      blue: Color(0xFF3B82F6),
    ),

    'light_green': AppThemeData(
      id: 'light_green',
      name: 'Fresh Mint',
      icon: '🌿',
      isDark: false,
      background: Color(0xFFF8FCF8),
      surface: Color(0xFFFFFFFF),
      card: Color(0xFFFFFFFF),
      border: Color(0xFFDCEDDC),
      borderHighlight: Color(0xFFC5DBC5),
      textPrimary: Color(0xFF1E3B1E),
      textSecondary: Color(0xFF4B6B4B),
      textMuted: Color(0xFF7A9A7A),
      primary: Color(0xFF10B981),
      secondary: Color(0xFF059669),
      accent: Color(0xFF84CC16),
      positive: Color(0xFF10B981),
      negative: Color(0xFFEF4444),
      cyan: Color(0xFF14B8A6),
      orange: Color(0xFF84CC16),
      purple: Color(0xFF8B5CF6),
      yellow: Color(0xFFA3E635),
      blue: Color(0xFF059669),
    ),

    'light_purple': AppThemeData(
      id: 'light_purple',
      name: 'Lavender Dream',
      icon: '💜',
      isDark: false,
      background: Color(0xFFFAF8FC),
      surface: Color(0xFFFFFFFF),
      card: Color(0xFFFFFFFF),
      border: Color(0xFFE9E2F0),
      borderHighlight: Color(0xFFD8C8E8),
      textPrimary: Color(0xFF2E1E3B),
      textSecondary: Color(0xFF6B4B7A),
      textMuted: Color(0xFF9A7AAA),
      primary: Color(0xFF8B5CF6),
      secondary: Color(0xFFA855F7),
      accent: Color(0xFFEC4899),
      positive: Color(0xFF10B981),
      negative: Color(0xFFEF4444),
      cyan: Color(0xFFD946EF),
      orange: Color(0xFFEC4899),
      purple: Color(0xFF8B5CF6),
      yellow: Color(0xFFFBBF24),
      blue: Color(0xFFA855F7),
    ),

    'light_warm': AppThemeData(
      id: 'light_warm',
      name: 'Sunset Gold',
      icon: '🌅',
      isDark: false,
      background: Color(0xFFFFFBF5),
      surface: Color(0xFFFFFFFF),
      card: Color(0xFFFFFFFF),
      border: Color(0xFFF0E6D8),
      borderHighlight: Color(0xFFE8D8C0),
      textPrimary: Color(0xFF3B2E1E),
      textSecondary: Color(0xFF7A6B4B),
      textMuted: Color(0xFFAA9A7A),
      primary: Color(0xFFF59E0B),
      secondary: Color(0xFFF97316),
      accent: Color(0xFFEF4444),
      positive: Color(0xFF10B981),
      negative: Color(0xFFEF4444),
      cyan: Color(0xFFF97316),
      orange: Color(0xFFF97316),
      purple: Color(0xFFEC4899),
      yellow: Color(0xFFF59E0B),
      blue: Color(0xFFEA580C),
    ),
  };

  /// Get theme by ID
  static AppThemeData getTheme(String id) {
    return themes[id] ?? themes['dark_cyan']!;
  }

  /// Get dark themes only
  static List<AppThemeData> get darkThemes =>
      themes.values.where((t) => t.isDark).toList();

  /// Get light themes only
  static List<AppThemeData> get lightThemes =>
      themes.values.where((t) => !t.isDark).toList();
}
