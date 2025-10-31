class ReflexScoreViewModel {
  ReflexScoreViewModel({
    required this.reflexName,
    required this.yesCount,
    required this.totalCount,
  });

  final String reflexName;
  final int yesCount;
  final int totalCount;

  double get ratio => totalCount == 0 ? 0 : yesCount / totalCount;
  int get percentage => (ratio * 100).round();
}

class ReflexScoreMapper {
  static List<ReflexScoreViewModel> fromSummary(
    Map<String, List<int>> summary,
  ) {
    return summary.entries
        .map(
          (entry) => ReflexScoreViewModel(
            reflexName: entry.key,
            yesCount: entry.value.isNotEmpty ? entry.value.first : 0,
            totalCount: entry.value.length > 1 ? entry.value[1] : 0,
          ),
        )
        .toList()
      ..sort((a, b) => a.reflexName.compareTo(b.reflexName));
  }

  static List<ReflexScoreViewModel> fromStoredScores(
    Map<String, dynamic> scores,
  ) {
    return scores.entries
        .map(
          (entry) => ReflexScoreViewModel(
            reflexName: entry.key,
            yesCount: (entry.value['yes'] as num?)?.round() ?? 0,
            totalCount: (entry.value['total'] as num?)?.round() ?? 0,
          ),
        )
        .toList()
      ..sort((a, b) => a.reflexName.compareTo(b.reflexName));
  }
}
