import 'dart:collection';

/// Represents a single day in a progress overview.
///
/// The node stores meta information whether the day had
/// training planned, if it was completed and if it contained
/// special markers such as a golden day. Reflection data is
/// derived from the stored notes on the corresponding
/// calendar event.
class DayProgressNode {
  DayProgressNode({
    required DateTime date,
    required this.isPlanned,
    required this.isCompleted,
    this.isGoldenDay = false,
    this.hasReflection = false,
  }) : date = DateTime(date.year, date.month, date.day);

  /// Normalised date (time set to midnight).
  final DateTime date;

  /// True when the day contains at least one scheduled training.
  final bool isPlanned;

  /// True when one of the scheduled trainings was marked as completed.
  final bool isCompleted;

  /// Whether the day is flagged as a "golden day".
  final bool isGoldenDay;

  /// Indicates whether a reflection or day summary exists for that day.
  final bool hasReflection;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// True when the node represents the current day.
  bool get isToday => date == _today;

  /// True when the node is in the future.
  bool get isFuture => date.isAfter(_today);

  /// True when the node is in the past.
  bool get isPast => date.isBefore(_today);

  /// Helper indicating if a reflection prompt should be shown.
  bool get requiresReflection => isCompleted && !hasReflection && isPast;
}

/// Core representation of a seven day progress window.
class CoreWeekProgress {
  CoreWeekProgress({
    required DateTime windowStart,
    required DateTime windowEnd,
    required Iterable<DayProgressNode> days,
  })  : windowStart = DateTime(windowStart.year, windowStart.month, windowStart.day),
        windowEnd = DateTime(windowEnd.year, windowEnd.month, windowEnd.day),
        _days = List<DayProgressNode>.unmodifiable(
          (List<DayProgressNode>.from(days)..sort((a, b) => a.date.compareTo(b.date))),
        );

  /// Inclusive window start of the tracked seven day period.
  final DateTime windowStart;

  /// Inclusive window end of the tracked seven day period.
  final DateTime windowEnd;

  final List<DayProgressNode> _days;

  /// Unmodifiable view of the stored days in chronological order.
  UnmodifiableListView<DayProgressNode> get days => UnmodifiableListView(_days);

  /// Number of days that contain a planned training session.
  int get plannedDaysCount => _days.where((d) => d.isPlanned).length;

  /// Number of days with completed training sessions.
  int get completedDaysCount => _days.where((d) => d.isCompleted).length;

  /// Completion ratio for the tracked window.
  double get progressRatio {
    if (plannedDaysCount == 0) {
      return 0;
    }
    return completedDaysCount / plannedDaysCount;
  }

  /// Returns the index of the current day inside the window or `null` if not present.
  int? get todayIndex {
    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);
    for (var i = 0; i < _days.length; i++) {
      if (_days[i].date == normalized) {
        return i;
      }
    }
    return null;
  }

  /// Returns true if any day in the week is flagged as golden day.
  bool get hasGoldenDay => _days.any((d) => d.isGoldenDay);

  /// Convenience getter exposing derived statistics.
  WeekProgressStats get stats => WeekProgressStats(
        plannedDays: plannedDaysCount,
        completedDays: completedDaysCount,
        pendingReflections:
            _days.where((node) => node.requiresReflection).length,
      );
}

/// Aggregated statistics for a [`CoreWeekProgress`].
class WeekProgressStats {
  const WeekProgressStats({
    required this.plannedDays,
    required this.completedDays,
    required this.pendingReflections,
  });

  final int plannedDays;
  final int completedDays;
  final int pendingReflections;

  bool get hasPlannedDays => plannedDays > 0;

  /// Whether there is at least one day that should prompt a reflection.
  bool get hasPendingReflections => pendingReflections > 0;
}
