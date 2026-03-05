import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'achievement_service.dart';
import 'game_service.dart';
import 'tutorial_service.dart';

/// Service for automatic game state persistence
class AutoSaveService {
  static const String _gameStateKey = 'kandl_game_state';
  static const String _tutorialStateKey = 'kandl_tutorial_state';
  static const String _achievementStateKey = 'kandl_achievement_state';
  static const String _lastSaveKey = 'kandl_last_save';

  // Auto-save interval (30 seconds)
  static const Duration _autoSaveInterval = Duration(seconds: 30);

  SharedPreferences? _prefs;
  Timer? _autoSaveTimer;
  GameService? _gameService;
  TutorialService? _tutorialService;
  AchievementService? _achievementService;

  bool _initialized = false;
  bool _isDirty = false; // Track if there are unsaved changes

  /// Initialize the auto-save service
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// Bind services and start auto-saving
  void bindServices(GameService game, TutorialService tutorial, AchievementService achievements) {
    _gameService = game;
    _tutorialService = tutorial;
    _achievementService = achievements;

    // Listen to game changes
    _gameService!.addListener(_onGameChanged);
    _tutorialService!.addListener(_onTutorialChanged);
    _achievementService!.addListener(_onAchievementChanged);

    // Start periodic auto-save
    _startAutoSaveTimer();
  }

  /// Unbind services and stop auto-saving
  void dispose() {
    _autoSaveTimer?.cancel();
    _gameService?.removeListener(_onGameChanged);
    _tutorialService?.removeListener(_onTutorialChanged);
    _achievementService?.removeListener(_onAchievementChanged);
  }

  void _onGameChanged() {
    _isDirty = true;
  }

  void _onTutorialChanged() {
    _isDirty = true;
  }

  void _onAchievementChanged() {
    _isDirty = true;
  }

  void _startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (_) {
      if (_isDirty) {
        save();
      }
    });
  }

  /// Check if a saved game exists
  bool get hasSavedGame {
    if (!_initialized || _prefs == null) return false;
    return _prefs!.containsKey(_gameStateKey);
  }

  /// Get last save timestamp
  DateTime? get lastSaveTime {
    if (!_initialized || _prefs == null) return null;
    final timestamp = _prefs!.getString(_lastSaveKey);
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  /// Save game state immediately
  Future<bool> save() async {
    if (!_initialized || _prefs == null || _gameService == null) {
      debugPrint('AutoSave: Not initialized, cannot save');
      return false;
    }

    try {
      // Save game state
      final gameData = _gameService!.toJson();
      final gameJson = jsonEncode(gameData);
      await _prefs!.setString(_gameStateKey, gameJson);

      // Save tutorial state
      if (_tutorialService != null) {
        final tutorialData = _tutorialService!.toJson();
        final tutorialJson = jsonEncode(tutorialData);
        await _prefs!.setString(_tutorialStateKey, tutorialJson);
      }

      // Save achievement state
      if (_achievementService != null) {
        final achievementData = _achievementService!.toJson();
        final achievementJson = jsonEncode(achievementData);
        await _prefs!.setString(_achievementStateKey, achievementJson);
      }

      // Save timestamp
      await _prefs!.setString(_lastSaveKey, DateTime.now().toIso8601String());

      _isDirty = false;
      debugPrint('AutoSave: Game saved successfully');
      return true;
    } catch (e) {
      debugPrint('AutoSave: Failed to save - $e');
      return false;
    }
  }

  /// Load saved game state
  Future<bool> load() async {
    if (!_initialized || _prefs == null || _gameService == null) {
      debugPrint('AutoSave: Not initialized, cannot load');
      return false;
    }

    try {
      // Load game state
      final gameJson = _prefs!.getString(_gameStateKey);
      if (gameJson == null) {
        debugPrint('AutoSave: No saved game found');
        return false;
      }

      final gameData = jsonDecode(gameJson) as Map<String, dynamic>;
      _gameService!.loadFromJson(gameData);

      // Load tutorial state
      if (_tutorialService != null) {
        final tutorialJson = _prefs!.getString(_tutorialStateKey);
        if (tutorialJson != null) {
          final tutorialData = jsonDecode(tutorialJson) as Map<String, dynamic>;
          _tutorialService!.fromJson(tutorialData);
        }
      }

      // Load achievement state
      if (_achievementService != null) {
        final achievementJson = _prefs!.getString(_achievementStateKey);
        if (achievementJson != null) {
          final achievementData = jsonDecode(achievementJson) as Map<String, dynamic>;
          _achievementService!.loadFromJson(achievementData);
        }
      }

      _isDirty = false;
      debugPrint('AutoSave: Game loaded successfully');
      return true;
    } catch (e) {
      debugPrint('AutoSave: Failed to load - $e');
      return false;
    }
  }

  /// Delete saved game
  Future<bool> deleteSave() async {
    if (!_initialized || _prefs == null) return false;

    try {
      await _prefs!.remove(_gameStateKey);
      await _prefs!.remove(_tutorialStateKey);
      await _prefs!.remove(_achievementStateKey);
      await _prefs!.remove(_lastSaveKey);
      debugPrint('AutoSave: Save deleted');
      return true;
    } catch (e) {
      debugPrint('AutoSave: Failed to delete save - $e');
      return false;
    }
  }

  /// Force save (call on important events like completing a trade)
  void markDirtyAndSave() {
    _isDirty = true;
    save();
  }
}
