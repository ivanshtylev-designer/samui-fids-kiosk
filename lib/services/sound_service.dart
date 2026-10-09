import 'sound_service_stub.dart'
    if (dart.library.js_interop) 'sound_service_web.dart';

class SoundService {
  static void playChime() {
    playPlatformChime();
  }
}
