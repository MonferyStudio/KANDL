import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Manages game sound effects
class SoundService extends ChangeNotifier {
  static final SoundService _instance = SoundService._();
  factory SoundService() => _instance;
  SoundService._();

  static const _poolSize = 4;
  final List<AudioPlayer> _pool = [];
  int _poolIndex = 0;
  bool _available = true;
  bool _enabled = true;
  double _volume = 0.5;

  // Debounce: prevent the same sound from playing twice within 150ms
  // (nested HoverRow/HoverScale/GlassCard fire overlapping taps)
  final Map<String, int> _lastPlayTime = {};
  static const _debounceMs = 150;

  bool get enabled => _enabled;
  double get volume => _volume;

  AudioPlayer? _getNextPlayer() {
    if (!_available) return null;
    try {
      // Lazily create pool members
      while (_pool.length < _poolSize) {
        final p = AudioPlayer();
        p.setReleaseMode(ReleaseMode.stop);
        _pool.add(p);
      }
      final player = _pool[_poolIndex];
      _poolIndex = (_poolIndex + 1) % _poolSize;
      return player;
    } catch (_) {
      _available = false;
      return null;
    }
  }

  void toggleSound() {
    _enabled = !_enabled;
    notifyListeners();
  }

  void setVolume(double v) {
    _volume = v.clamp(0.0, 1.0);
    notifyListeners();
  }

  Future<void> _play(String asset) async {
    if (!_enabled || !_available) return;

    // Debounce: skip if same sound was played within _debounceMs
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _lastPlayTime[asset] ?? 0;
    if (now - last < _debounceMs) return;
    _lastPlayTime[asset] = now;

    try {
      final player = _getNextPlayer();
      if (player == null) return;
      await player.setVolume(_volume);
      await player.play(AssetSource('sounds/$asset'));
    } catch (_) {
      // Silently fail — sound is non-critical
    }
  }

  void playClick() => _play('click.wav');
  void playMoney() => _play('money.wav');
  void playNotification() => _play('notification.wav');
  void playSell() => _play('sell.wav');
  void playBuy() => _play('buy.wav');

  // Casual update sounds — reuse existing assets with volume variations
  void playQuotaFanfare() => _play('money.wav'); // Epic quota clear
  void playCashRegister() => _play('money.wav'); // Robot income
  void playMilestone() => _play('notification.wav'); // Milestone reached
  void playConfetti() => _play('sell.wav'); // Winning trade confetti
  void playAth() => _play('notification.wav'); // All-time high

  @override
  void dispose() {
    for (final p in _pool) {
      p.dispose();
    }
    _pool.clear();
    super.dispose();
  }
}
