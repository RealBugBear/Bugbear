import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

class Beeper {
  Beeper._();

  static final AudioPlayer _player = AudioPlayer();
  static bool _configured = false;
  static Uint8List? _cachedBeep;

  static Future<void> _ensureConfigured() async {
    if (_configured) {
      return;
    }
    await _player.setReleaseMode(ReleaseMode.stop);
    _configured = true;
  }

  static Future<void> beep() async {
    await _ensureConfigured();
    _cachedBeep ??= _generateBeep();
    await _player.play(BytesSource(_cachedBeep!));
  }

  static Uint8List _generateBeep() {
    const sampleRate = 22050;
    const frequency = 880.0;
    const durationSeconds = 0.25;
    const amplitude = 0.35;
    final sampleCount = (sampleRate * durationSeconds).round();

    final pcmDataBuilder = BytesBuilder();
    for (var i = 0; i < sampleCount; i++) {
      final time = i / sampleRate;
      final sample = sin(2 * pi * frequency * time);
      final amplitudeScaled = (sample * amplitude * 0x7fff).round();
      pcmDataBuilder.add(_int16le(amplitudeScaled));
    }
    final pcmData = pcmDataBuilder.toBytes();

    final wavBuilder = BytesBuilder();
    void writeString(String value) => wavBuilder.add(ascii.encode(value));
    void writeInt32(int value) => wavBuilder.add(_int32le(value));
    void writeInt16(int value) => wavBuilder.add(_int16le(value));

    writeString('RIFF');
    writeInt32(36 + pcmData.length);
    writeString('WAVE');
    writeString('fmt ');
    writeInt32(16); // PCM chunk size
    writeInt16(1); // audio format PCM
    writeInt16(1); // channels
    writeInt32(sampleRate);
    writeInt32(sampleRate * 2); // byte rate (sampleRate * channels * bytesPerSample)
    writeInt16(2); // block align (channels * bytesPerSample)
    writeInt16(16); // bits per sample
    writeString('data');
    writeInt32(pcmData.length);
    wavBuilder.add(pcmData);

    return wavBuilder.toBytes();
  }

  static List<int> _int16le(int value) {
    final v = value & 0xffff;
    return [v & 0xff, (v >> 8) & 0xff];
  }

  static List<int> _int32le(int value) {
    final v = value & 0xffffffff;
    return [
      v & 0xff,
      (v >> 8) & 0xff,
      (v >> 16) & 0xff,
      (v >> 24) & 0xff,
    ];
  }
}
