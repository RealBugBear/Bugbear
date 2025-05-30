import 'package:flutter/material.dart';

/// ControlButtonRow zeigt drei Actions an:
/// - Zurück
/// - Play/Pause (Icon wechselt je nach Status)
/// - Weiter
class ControlButtonRow extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final bool isPlaying;

  const ControlButtonRow({
    super.key,
    required this.onBack,
    required this.onPlayPause,
    required this.onNext,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Zurück-Button
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
            tooltip: 'Zurück',
          ),
          // Play/Pause-Button
          IconButton(
            iconSize: 48,
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: onPlayPause,
            tooltip: isPlaying ? 'Pause' : 'Play',
          ),
          // Weiter-Button
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.arrow_forward),
            onPressed: onNext,
            tooltip: 'Weiter',
          ),
        ],
      ),
    );
  }
}
