class TrainingIntent {
  final TrainingIntentType type;
  final String? sessionId;

  const TrainingIntent._(this.type, this.sessionId);

  factory TrainingIntent.start() => const TrainingIntent._(TrainingIntentType.start, null);

  factory TrainingIntent.resume(String sessionId) =>
      TrainingIntent._(TrainingIntentType.resume, sessionId);
}

enum TrainingIntentType { start, resume }
