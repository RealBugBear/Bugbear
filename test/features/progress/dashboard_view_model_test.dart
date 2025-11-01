import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:free_base/features/common/state/dashboard_view_model.dart';
import 'package:free_base/features/progress/state/progress_store.dart';
import 'package:free_base/features/training/models/session_state.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/services/reminder/reminder_service.dart';

class _MockSessionNotifier extends Mock implements SessionNotifier {}

class _MockProgressStore extends Mock implements ProgressStore {}

class _MockReminderService extends Mock implements ReminderService {}

void main() {
  group('DashboardViewModel', () {
    late _MockSessionNotifier sessionNotifier;
    late _MockProgressStore progressStore;
    late _MockReminderService reminderService;

    setUp(() {
      sessionNotifier = _MockSessionNotifier();
      progressStore = _MockProgressStore();
      reminderService = _MockReminderService();

      when(sessionNotifier.addListener(any)).thenAnswer((_) {});
      when(sessionNotifier.removeListener(any)).thenAnswer((_) {});
      when(progressStore.addListener(any)).thenAnswer((_) {});
      when(progressStore.removeListener(any)).thenAnswer((_) {});
      when(reminderService.addListener(any)).thenAnswer((_) {});
      when(reminderService.removeListener(any)).thenAnswer((_) {});
      when(reminderService.scheduledTime).thenReturn(null);
      when(reminderService.hasScheduledReminder).thenReturn(false);

      when(sessionNotifier.state).thenReturn(
        SessionState(
          phaseId: 'phase',
          exerciseIndex: 0,
          completedReps: 0,
          remainingSeconds: 0,
          startedAt: DateTime.now(),
        ),
      );
    });

    test('produces week progress based on stored completions', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final earlier = today.subtract(const Duration(days: 3));
      final completions = <DateTime, bool>{
        today: true,
        yesterday: true,
        earlier: false,
      };

      when(progressStore.isDayCompleted(any)).thenAnswer((invocation) {
        final day = invocation.positionalArguments.first as DateTime;
        final normalized = DateTime(day.year, day.month, day.day);
        return completions[normalized] ?? false;
      });

      final viewModel = DashboardViewModel(
        sessionNotifier,
        progressStore,
        reminderService,
        autoplayEnabled: false,
        audioEnabled: false,
      );

      final progress = viewModel.currentWeekProgress;
      final plannedDays = progress.plannedDaysCount;
      expect(progress.completedDaysCount, 2);
      expect(viewModel.progressRatio, closeTo(2 / plannedDays, 0.001));
      expect(progress.todayIndex, isNotNull);
      expect(progress.days[progress.todayIndex!].isToday, isTrue);
    });
  });
}
