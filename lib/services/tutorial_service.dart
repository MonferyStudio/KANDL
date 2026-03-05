import 'package:flutter/foundation.dart';

import '../core/core.dart';

/// Enum for all tutorial steps
enum TutorialStep {
  // Initial welcome popup
  welcome,

  // Dashboard contextual tutorials
  dashboardIntro,
  metricsBar,
  statsBar,

  // Dashboard widget tutorials
  positionStatistics,
  tradingPerformance,
  riskMetrics,
  milestoneProgress,
  challengesPanel,
  recentTrades,
  positionNews,

  // Navigation tutorials
  sectorsPrompt,
  sectorsIntro,
  stocksPrompt,
  stocksIntro,
  tradingPrompt,
  tradingIntro,

  // First purchase flow
  firstBuyPrompt,
  positionsIntro,

  // Feature tutorials (triggered by events)
  upgradesIntro,
  prestigeShopIntro,
  achievementsIntro,
  fintokIntro,
  informantIntro,

  // Completed
  completed,
}

/// Service for managing tutorial state and progression
class TutorialService extends ChangeNotifier {
  TutorialStep _currentStep = TutorialStep.welcome;
  bool _tutorialSkipped = false;
  bool _welcomeCompleted = false;
  bool _waitingForNewsToClose = false;

  // Track which features have been introduced
  final Set<String> _introducedFeatures = {};

  // Getters
  TutorialStep get currentStep => _currentStep;
  bool get tutorialSkipped => _tutorialSkipped;
  bool get welcomeCompleted => _welcomeCompleted;
  bool get waitingForNewsToClose => _waitingForNewsToClose;
  bool get isActive => !_tutorialSkipped && _currentStep != TutorialStep.completed && !_waitingForNewsToClose;

  /// Check if we should show the welcome popup
  bool get shouldShowWelcome =>
      !_tutorialSkipped &&
      !_welcomeCompleted &&
      _currentStep == TutorialStep.welcome;

  /// Check if a specific feature was introduced
  bool wasIntroduced(String featureId) => _introducedFeatures.contains(featureId);

  /// Mark feature as introduced
  void markIntroduced(String featureId) {
    _introducedFeatures.add(featureId);
    notifyListeners();
  }

  /// Complete the welcome popup - wait for news to close before starting tutorials
  void completeWelcome() {
    _welcomeCompleted = true;
    _waitingForNewsToClose = true;
    notifyListeners();
  }

  /// Start contextual tutorials after news popup is closed
  void startContextualTutorials() {
    if (_waitingForNewsToClose && !_tutorialSkipped) {
      _waitingForNewsToClose = false;
      _currentStep = TutorialStep.dashboardIntro;
      notifyListeners();
    }
  }

  /// Skip all tutorials
  void skipAll() {
    _tutorialSkipped = true;
    _welcomeCompleted = true;
    _currentStep = TutorialStep.completed;
    notifyListeners();
  }

  /// Advance to next tutorial step
  void nextStep() {
    final nextIndex = _currentStep.index + 1;
    if (nextIndex < TutorialStep.values.length) {
      _currentStep = TutorialStep.values[nextIndex];
    } else {
      _currentStep = TutorialStep.completed;
    }
    notifyListeners();
  }

  /// Jump to a specific step
  void goToStep(TutorialStep step) {
    _currentStep = step;
    notifyListeners();
  }

  /// Complete current step and optionally jump to another
  void completeStep([TutorialStep? nextStep]) {
    if (nextStep != null) {
      _currentStep = nextStep;
    } else {
      this.nextStep();
    }
    notifyListeners();
  }

  /// Trigger tutorial for a specific feature (called by game events)
  void triggerFeatureTutorial(String featureId) {
    if (_tutorialSkipped || wasIntroduced(featureId)) return;

    switch (featureId) {
      case 'upgrades':
        if (_currentStep.index >= TutorialStep.positionsIntro.index) {
          _currentStep = TutorialStep.upgradesIntro;
          markIntroduced(featureId);
        }
        break;
      case 'prestige':
        if (_currentStep.index >= TutorialStep.upgradesIntro.index) {
          _currentStep = TutorialStep.prestigeShopIntro;
          markIntroduced(featureId);
        }
        break;
      case 'achievements':
        _currentStep = TutorialStep.achievementsIntro;
        markIntroduced(featureId);
        break;
      case 'fintok':
        _currentStep = TutorialStep.fintokIntro;
        markIntroduced(featureId);
        break;
      case 'informant':
        _currentStep = TutorialStep.informantIntro;
        markIntroduced(featureId);
        break;
    }
    notifyListeners();
  }

  /// Restart the tutorial from the beginning
  void restart() {
    _tutorialSkipped = false;
    _welcomeCompleted = false;
    _currentStep = TutorialStep.welcome;
    _introducedFeatures.clear();
    notifyListeners();
  }

  /// Mark the tutorial as fully completed
  void complete() {
    _currentStep = TutorialStep.completed;
    notifyListeners();
  }

  /// Check if the current step requires a specific view
  /// Returns the required ViewType or null if no specific view is required
  ViewType? get requiredViewForCurrentStep {
    switch (_currentStep) {
      case TutorialStep.sectorsIntro:
      case TutorialStep.stocksIntro:
        return ViewType.market;
      case TutorialStep.tradingIntro:
      case TutorialStep.firstBuyPrompt:
        return ViewType.trading;
      case TutorialStep.positionsIntro:
        return ViewType.portfolio;
      default:
        return null;
    }
  }

  /// Called when the user navigates to a new view
  /// Auto-advances from prompt steps to intro steps when the expected view is reached
  void onViewChanged(ViewType newView) {
    if (_tutorialSkipped || _currentStep == TutorialStep.completed) return;

    switch (_currentStep) {
      case TutorialStep.sectorsPrompt:
        if (newView == ViewType.market) {
          _currentStep = TutorialStep.sectorsIntro;
          notifyListeners();
        }
        break;
      case TutorialStep.sectorsIntro:
        // User clicked a sector card, which switches to stocks sub-tab
        if (newView == ViewType.market) {
          _currentStep = TutorialStep.stocksIntro;
          notifyListeners();
        }
        break;
      case TutorialStep.stocksPrompt:
        if (newView == ViewType.market) {
          _currentStep = TutorialStep.stocksIntro;
          notifyListeners();
        }
        break;
      case TutorialStep.stocksIntro:
        // User clicked a stock row, which navigates to trading view
        if (newView == ViewType.trading) {
          _currentStep = TutorialStep.tradingIntro;
          notifyListeners();
        }
        break;
      case TutorialStep.tradingPrompt:
        if (newView == ViewType.trading) {
          _currentStep = TutorialStep.tradingIntro;
          notifyListeners();
        }
        break;
      default:
        break;
    }
  }

  /// Check if current step is a "prompt" step that waits for user interaction
  bool get isWaitingForNavigation {
    return _currentStep == TutorialStep.sectorsPrompt ||
           _currentStep == TutorialStep.sectorsIntro ||
           _currentStep == TutorialStep.stocksPrompt ||
           _currentStep == TutorialStep.stocksIntro ||
           _currentStep == TutorialStep.tradingPrompt;
  }

  // === JSON SERIALIZATION ===

  Map<String, dynamic> toJson() => {
    'currentStep': _currentStep.index,
    'tutorialSkipped': _tutorialSkipped,
    'welcomeCompleted': _welcomeCompleted,
    'waitingForNewsToClose': _waitingForNewsToClose,
    'introducedFeatures': _introducedFeatures.toList(),
  };

  void fromJson(Map<String, dynamic> json) {
    final stepIndex = json['currentStep'] as int? ?? 0;
    _currentStep = stepIndex < TutorialStep.values.length
        ? TutorialStep.values[stepIndex]
        : TutorialStep.welcome;
    _tutorialSkipped = json['tutorialSkipped'] as bool? ?? false;
    _welcomeCompleted = json['welcomeCompleted'] as bool? ?? false;
    _waitingForNewsToClose = json['waitingForNewsToClose'] as bool? ?? false;

    final features = json['introducedFeatures'] as List<dynamic>? ?? [];
    _introducedFeatures.clear();
    _introducedFeatures.addAll(features.cast<String>());

    notifyListeners();
  }

  void reset() {
    _currentStep = TutorialStep.welcome;
    _tutorialSkipped = false;
    _welcomeCompleted = false;
    _waitingForNewsToClose = false;
    _introducedFeatures.clear();
    notifyListeners();
  }
}
