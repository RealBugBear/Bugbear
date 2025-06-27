// lib/features/calendar/services/golden_day_service.dart

/// GoldenDayService
///
/// Provides logic to calculate the next golden day for a phase.
class GoldenDayService {
  /// Calculates the upcoming Golden Day based on the phase start [phaseStart]
  /// and the amount of completed sessions per week [weeklyCounts].
  ///
  /// [weeklyCounts] should use the week index starting at `0` for the first
  /// week. Each value represents how many training sessions were completed in
  /// that week. Normally six sessions are expected each week. If fewer or more
  /// sessions were done, the Golden Day is shifted later or earlier
  /// accordingly.
  DateTime calculateGoldenDay(
      DateTime phaseStart, Map<int, int> weeklyCounts) {
    // normalize phaseStart to remove any time component
    final start = DateTime(phaseStart.year, phaseStart.month, phaseStart.day);

    // number of fully completed weeks
    final weeks = weeklyCounts.length;

    // accumulated shift due to weeks with not exactly six sessions
    var shift = 0;
    for (final entry in weeklyCounts.entries) {
      shift += (6 - entry.value);
    }

    return start.add(Duration(days: 6 + weeks * 7 + shift));
  }
}

