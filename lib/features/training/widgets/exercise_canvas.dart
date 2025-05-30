import 'package:flutter/material.dart';

/// ExerciseCanvas zeigt eine Übungs-Grafik oder -Animation mittig an.
/// Der Container wächst flexibel, behält aber ein Seitenverhältnis bei.
class ExerciseCanvas extends StatelessWidget {
  /// Pfad zur Bild- oder Animationsdatei im Assets-Ordner.
  final String imagePath;

  /// Optionales Seitenverhältnis, z.B. 1.0 für Quadrat. Default: passt Container-Höhe.
  final double? aspectRatio;

  const ExerciseCanvas({
    super.key,
    required this.imagePath,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Image.asset(
      imagePath,
      fit: BoxFit.contain,
    );

    // Falls ein aspectRatio gewünscht, in AspectRatio-Widget einbetten
    if (aspectRatio != null) {
      content = AspectRatio(
        aspectRatio: aspectRatio!,
        child: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Center(child: content),
    );
  }
}
