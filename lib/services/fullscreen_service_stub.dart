import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

bool _wmInitialized = false;

bool get _isDesktop =>
    Platform.isWindows || Platform.isMacOS || Platform.isLinux;

/// Non-web: desktop uses window_manager, mobile uses SystemChrome
Future<void> enterFullscreen() async {
  if (_isDesktop) {
    if (!_wmInitialized) await initFullscreen();
    await windowManager.setFullScreen(true);
  } else {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
}

Future<void> exitFullscreen() async {
  if (_isDesktop) {
    if (!_wmInitialized) await initFullscreen();
    await windowManager.setFullScreen(false);
  } else {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}

Future<void> initFullscreen() async {
  if (_isDesktop && !_wmInitialized) {
    await windowManager.ensureInitialized();
    _wmInitialized = true;
  }
}
