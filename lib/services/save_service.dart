import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';

import 'game_service.dart';
import 'tutorial_service.dart';

// Conditional imports for web
import 'save_service_stub.dart'
    if (dart.library.html) 'save_service_web.dart' as platform;

/// Service for saving and loading game data
class SaveService {
  /// Export game data to JSON file
  static Future<SaveResult> exportSave(GameService game, {TutorialService? tutorial}) async {
    try {
      final saveData = game.toJson();
      // Include tutorial state in save
      if (tutorial != null) {
        saveData['tutorialState'] = tutorial.toJson();
      }
      final jsonString = const JsonEncoder.withIndent('  ').convert(saveData);
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final fileName = 'kandl_save_$timestamp.json';

      if (kIsWeb) {
        // For web, use HTML download
        platform.downloadFile(jsonString, fileName);
        return SaveResult.success('Save exported successfully!');
      } else {
        // For desktop/mobile, use file_picker
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Export Save File',
          fileName: fileName,
          allowedExtensions: ['json'],
          type: FileType.custom,
        );

        if (result != null) {
          // Write the file to the selected path
          await platform.writeFile(result, jsonString);
          return SaveResult.success('Save exported to: $result');
        } else {
          return SaveResult.cancelled();
        }
      }
    } catch (e) {
      return SaveResult.error('Failed to export save: $e');
    }
  }

  /// Import game data from JSON file
  static Future<SaveResult> importSave(GameService game, {TutorialService? tutorial}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Load Save File',
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return SaveResult.cancelled();
      }

      final file = result.files.first;
      String jsonString;

      if (file.bytes != null) {
        jsonString = utf8.decode(file.bytes!);
      } else if (!kIsWeb && file.path != null) {
        jsonString = await platform.readFile(file.path!);
      } else {
        return SaveResult.error('Could not read file');
      }

      final saveData = json.decode(jsonString) as Map<String, dynamic>;

      // Validate save data
      if (!_isValidSaveData(saveData)) {
        return SaveResult.error('Invalid save file format');
      }

      // Load the save into game
      game.loadFromJson(saveData);

      // Restore tutorial state if available
      if (tutorial != null && saveData.containsKey('tutorialState')) {
        tutorial.fromJson(saveData['tutorialState'] as Map<String, dynamic>);
      }

      return SaveResult.success('Save imported successfully!');
    } catch (e) {
      return SaveResult.error('Failed to import save: $e');
    }
  }

  /// Validate save data structure
  static bool _isValidSaveData(Map<String, dynamic> data) {
    // Check for required fields
    return data.containsKey('version') &&
        data.containsKey('gameState') &&
        data['gameState'] is Map;
  }
}

/// Result of save/load operation
class SaveResult {
  final bool success;
  final bool cancelled;
  final String? message;
  final String? error;

  SaveResult._({
    required this.success,
    this.cancelled = false,
    this.message,
    this.error,
  });

  factory SaveResult.success(String message) {
    return SaveResult._(success: true, message: message);
  }

  factory SaveResult.error(String error) {
    return SaveResult._(success: false, error: error);
  }

  factory SaveResult.cancelled() {
    return SaveResult._(success: false, cancelled: true);
  }
}
