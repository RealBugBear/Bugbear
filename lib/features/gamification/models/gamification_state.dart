import 'package:hive/hive.dart';

part 'gamification_state.g.dart';

@HiveType(typeId: 4)
class GamificationState {
  const GamificationState({
    this.level = 1,
    this.nextThreshold = 100,
    this.freezeTokens = 0,
  });

  @HiveField(0)
  final int level;

  @HiveField(1)
  final int nextThreshold;

  @HiveField(2)
  final int freezeTokens;

  GamificationState copyWith({
    int? level,
    int? nextThreshold,
    int? freezeTokens,
  }) {
    return GamificationState(
      level: level ?? this.level,
      nextThreshold: nextThreshold ?? this.nextThreshold,
      freezeTokens: freezeTokens ?? this.freezeTokens,
    );
  }
}
