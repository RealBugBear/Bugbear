import 'package:bugbear_app/features/training/models/exercise_item.dart';

/// Liefert für eine gegebene Phase eine Liste nummerierter ExerciseItems.
class ExerciseRepository {
  /// Mapping Phase → Anzahl Übungen (aus TrainingssystemuKalenderlogik.pdf).
  static const Map<String, int> _counts = {
    '0': 7,
    '1': 8,
    '2a': 4,
    '2b': 5,
    '3': 5,
    '4': 4,
    '5': 4,
    '6': 4,
    '7': 4,
    '8': 4,
    '9': 4,
  };

  /// Öffentlich zugängliche Liste aller Phase-IDs.
  List<String> get phaseIds => _counts.keys.toList();

  /// Generiert die Liste mit Übungsnummern und Platzhaltern.
  List<ExerciseItem> getExercisesForPhase(String phaseId) {
    final count = _counts[phaseId] ?? 0;
    return List.generate(count, (index) {
      final num = index + 1;
      return ExerciseItem(
        id: '$phaseId-$num',
        name: 'Übung $num',
        imagePath: 'assets/images/placeholder.png',
        activeSeconds: 8,
        restSeconds: 4,
        repetitions: 6,
      );
    });
  }
}
