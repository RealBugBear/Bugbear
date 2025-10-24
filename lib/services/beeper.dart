import 'package:audioplayers/audioplayers.dart';

class Beeper {
  Beeper._();

  static final AudioPlayer _player = AudioPlayer();
  static bool _configured = false;

  static Future<void> beep() async {
    if (!_configured) {
      await _player.setReleaseMode(ReleaseMode.stop);
      _configured = true;
    }
    await _player.play(const AssetSource('audio/beep.mp3'));
  }
}
