enum MoroExerciseType { phased4x, simple }

class MoroExerciseStep {
  final int order;
  final String text;
  final int? durationSec;

  const MoroExerciseStep({
    required this.order,
    required this.text,
    this.durationSec,
  });
}

class MoroBreathPattern {
  final String pattern;
  final int? exhaleSec;
  final int? holdSec;
  final String? notes;

  const MoroBreathPattern({
    required this.pattern,
    this.exhaleSec,
    this.holdSec,
    this.notes,
  });
}

class MoroMedia {
  final String? image;
  final String? video;

  const MoroMedia({
    this.image,
    this.video,
  });
}

class MoroExercise {
  final int index; // 1..7
  final String title;
  final MoroExerciseType type;
  final int repeats; // 1-5: 3 ; 6-7: 6
  final int phasesPerRepeat; // 1-5: 4 ; 6-7: 1
  final int baseSeconds; // 1-5: 3 (per phase) ; 6-7: 7 (per repeat)
  final int autoplayDefault; // seconds used for default autoplay pause
  final String goal;
  final String startPosition;
  final String? endPosition;
  final List<MoroExerciseStep> steps;
  final List<String> cues;
  final MoroBreathPattern breath;
  final List<String> abortRules;
  final String? notes;
  final List<String> tags;
  final String version;
  final MoroMedia media;
  final String resumeKey;
  final String? mediaFallbackImage;
  final int xpReward;

  const MoroExercise({
    required this.index,
    required this.title,
    required this.type,
    required this.repeats,
    required this.phasesPerRepeat,
    required this.baseSeconds,
    required this.autoplayDefault,
    required this.goal,
    required this.startPosition,
    this.endPosition,
    required this.steps,
    required this.cues,
    required this.breath,
    required this.abortRules,
    this.notes,
    required this.tags,
    required this.version,
    required this.media,
    required this.resumeKey,
    this.mediaFallbackImage,
    required this.xpReward,
  });
}
