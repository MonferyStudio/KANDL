// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation using Fullscreen API
Future<void> enterFullscreen() async {
  html.document.documentElement?.requestFullscreen();
}

Future<void> exitFullscreen() async {
  html.document.exitFullscreen();
}

Future<void> initFullscreen() async {}
