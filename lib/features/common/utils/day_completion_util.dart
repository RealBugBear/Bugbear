import 'package:free_base/features/calendar/notifier/calendar_notifier.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';

class DayCompletionResult {
  const DayCompletionResult({
    required this.date,
    required this.wasAlreadyCompleted,
    required this.requiresReflection,
  });

  final DateTime date;
  final bool wasAlreadyCompleted;
  final bool requiresReflection;
}

Future<DayCompletionResult> markDayCompletion({
  required SessionNotifier sessionNotifier,
  required CalendarNotifier calendarNotifier,
  required DateTime completionTime,
  int? xpReward,
}) async {
  final localCompletion = completionTime.toLocal();
  final normalized = DateTime(
    localCompletion.year,
    localCompletion.month,
    localCompletion.day,
  );

  if (xpReward != null && xpReward > 0) {
    sessionNotifier.applyXpReward(
      xp: xpReward,
      completionTime: localCompletion,
    );
  } else {
    final lastCompleted = sessionNotifier.state.lastCompletedOn;
    final alreadyTracked = lastCompleted != null &&
        lastCompleted.year == normalized.year &&
        lastCompleted.month == normalized.month &&
        lastCompleted.day == normalized.day;
    if (!alreadyTracked) {
      sessionNotifier.state = sessionNotifier.state.copyWith(
        lastCompletedOn: normalized,
      );
      sessionNotifier.updateStreakFreeze(referenceDate: normalized);
    }
  }

  final alreadyCompleted = calendarNotifier.dayIsCompleted(normalized);
  if (!alreadyCompleted) {
    await calendarNotifier.toggleDayCompleted(normalized);
  }

  return DayCompletionResult(
    date: normalized,
    wasAlreadyCompleted: alreadyCompleted,
    requiresReflection: calendarNotifier.requiresReflection(normalized),
  );
}
