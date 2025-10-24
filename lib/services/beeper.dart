import 'package:audioplayers/audioplayers.dart';

class Beeper {
  Beeper._();
  static final _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static Future<void> beep() => _player.play(AssetSource('sounds/start.mp3'));
}
