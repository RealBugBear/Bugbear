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
  ///
  /// The [phaseLengthWeeks] parameter specifies how many full weeks a phase
  /// should last before the Golden Day is shown.
  DateTime calculateGoldenDay(
    DateTime phaseStart,
    Map<int, int> weeklyCounts, {
    int phaseLengthWeeks = 4,
  }) {
    // normalize phaseStart to remove any time component
    final start = DateTime(phaseStart.year, phaseStart.month, phaseStart.day);

    // accumulated shift due to weeks with not exactly six sessions
    var shift = 0;
    var countedWeeks = 0;
    for (final entry in weeklyCounts.entries) {
      if (entry.value >= 3) {
        countedWeeks++;
      } else {
        phaseLengthWeeks += 1;
      }
      shift += (6 - entry.value);
    }

    final totalWeeks =
        countedWeeks >= phaseLengthWeeks ? countedWeeks : phaseLengthWeeks;
    return start.add(Duration(days: totalWeeks * 7 - 1 + shift));
  }
}

