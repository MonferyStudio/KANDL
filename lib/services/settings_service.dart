import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_themes.dart';
import '../l10n/app_localizations.dart';
import 'fullscreen_service_stub.dart'
    if (dart.library.html) 'fullscreen_service_web.dart' as fullscreen;

/// Service for managing app settings (theme, language, etc.)
class SettingsService extends ChangeNotifier {
  static const String _themeKey = 'theme_id';
  static const String _languageKey = 'language_code';
  static const String _fullscreenKey = 'fullscreen';
  static const String _expertModeKey = 'expert_mode';

  SharedPreferences? _prefs;

  // Current settings
  String _currentThemeId = 'dark_cyan';
  String _currentLanguage = 'en';
  bool _isFullscreen = false;
  bool _expertMode = false;

  // Getters
  String get currentThemeId => _currentThemeId;
  String get currentLanguage => _currentLanguage;
  AppThemeData get currentTheme => AppThemes.getTheme(_currentThemeId);
  Locale get currentLocale => Locale(_currentLanguage);
  bool get isFullscreen => _isFullscreen;
  bool get expertMode => _expertMode;

  /// Initialize settings from SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _currentThemeId = _prefs?.getString(_themeKey) ?? 'dark_cyan';
    _currentLanguage = _prefs?.getString(_languageKey) ?? 'en';
    _isFullscreen = _prefs?.getBool(_fullscreenKey) ?? false;
    _expertMode = _prefs?.getBool(_expertModeKey) ?? false;

    await fullscreen.initFullscreen();

    // Restore fullscreen state
    if (_isFullscreen) {
      await fullscreen.enterFullscreen();
    }

    notifyListeners();
  }

  /// Set theme
  Future<void> setTheme(String themeId) async {
    if (_currentThemeId == themeId) return;
    if (!AppThemes.themes.containsKey(themeId)) return;

    _currentThemeId = themeId;
    await _prefs?.setString(_themeKey, themeId);
    notifyListeners();
  }

  /// Set language
  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;
    if (!AppLocalizations.supportedLocales.contains(Locale(languageCode))) return;

    _currentLanguage = languageCode;
    await _prefs?.setString(_languageKey, languageCode);
    notifyListeners();
  }

  /// Toggle fullscreen mode
  Future<void> toggleFullscreen() async {
    _isFullscreen = !_isFullscreen;
    await _prefs?.setBool(_fullscreenKey, _isFullscreen);

    if (_isFullscreen) {
      await fullscreen.enterFullscreen();
    } else {
      await fullscreen.exitFullscreen();
    }

    notifyListeners();
  }

  /// Toggle expert mode
  Future<void> toggleExpertMode() async {
    _expertMode = !_expertMode;
    await _prefs?.setBool(_expertModeKey, _expertMode);
    notifyListeners();
  }

  /// Get all available themes
  List<AppThemeData> get availableThemes => AppThemes.themes.values.toList();

  /// Get all available languages
  List<LanguageOption> get availableLanguages => [
    LanguageOption(code: 'en', name: 'English', flag: '🇬🇧'),
    LanguageOption(code: 'fr', name: 'Français', flag: '🇫🇷'),
  ];
}

class LanguageOption {
  final String code;
  final String name;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
  });
}
