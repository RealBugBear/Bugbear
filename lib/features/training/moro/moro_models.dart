enum MoroExerciseType { phased4x, simple }

class MoroExercise {
  final int index; // 1..7
  final String title;
  final MoroExerciseType type;
  final int repeats;           // 1-5: 3 ; 6-7: 6
  final int phasesPerRepeat;   // 1-5: 4 ; 6-7: 1
  final int baseSeconds;       // 1-5: 3 (per phase) ; 6-7: 7 (per repeat)

  const MoroExercise({
    required this.index,
    required this.title,
    required this.type,
    required this.repeats,
    required this.phasesPerRepeat,
    required this.baseSeconds,
  });
}
