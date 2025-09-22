/// Feature flag configuration controlling access to optional app areas.
///
/// The flags default to `false` because they will later be hydrated from a
/// remote configuration source (see T5.x). Until then the application can
/// instantiate a constant set locally and provide it via a [Provider].
class FeatureFlags {
  final bool parentsTrackEnabled;
  final bool trainerTrackEnabled;
  final bool forumEnabled;
  final bool achievementsEnabled;

  const FeatureFlags({
    this.parentsTrackEnabled = false,
    this.trainerTrackEnabled = false,
    this.forumEnabled = false,
    this.achievementsEnabled = false,
  });

  FeatureFlags copyWith({
    bool? parentsTrackEnabled,
    bool? trainerTrackEnabled,
    bool? forumEnabled,
    bool? achievementsEnabled,
  }) {
    return FeatureFlags(
      parentsTrackEnabled:
          parentsTrackEnabled ?? this.parentsTrackEnabled,
      trainerTrackEnabled:
          trainerTrackEnabled ?? this.trainerTrackEnabled,
      forumEnabled: forumEnabled ?? this.forumEnabled,
      achievementsEnabled:
          achievementsEnabled ?? this.achievementsEnabled,
    );
  }
}
