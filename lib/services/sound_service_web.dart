import 'dart:js_interop';
import 'package:flutter/foundation.dart';

@JS('playChime')
external void _jsPlayChime();

void playPlatformChime() {
  try {
    _jsPlayChime();
  } catch (error, stack) {
    if (kDebugMode) {
      debugPrint('Web Audio playChime error: $error\n$stack');
    }
  }
}
