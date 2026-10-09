import 'dart:js_interop';

@JS('playChime')
external void _jsPlayChime();

void playPlatformChime() {
  try {
    _jsPlayChime();
  } catch (_) {}
}

