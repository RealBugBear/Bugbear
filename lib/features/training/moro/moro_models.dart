enum MoroExerciseType { phased4x, simple }

class MoroExercise {
  final int index;
  final String title;
  final MoroExerciseType type;
  final int repeats;
  final int phasesPerRepeat;
  final int baseSeconds;

  const MoroExercise({
    required this.index,
    required this.title,
    required this.type,
    required this.repeats,
    required this.phasesPerRepeat,
    required this.baseSeconds,
  });
}
