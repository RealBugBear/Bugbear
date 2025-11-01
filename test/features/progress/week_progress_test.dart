import 'package:flutter_test/flutter_test.dart';
import 'package:free_base/features/progress/models/week_progress.dart';

void main() {
  group('CoreWeekProgress', () {
    test('derives statistics for the active week window', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startOfWeek = today.subtract(
        Duration(days: today.weekday - DateTime.monday),
      );
      final todayOffset = today.difference(startOfWeek).inDays;

      final nodes = List<DayProgressNode>.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final isPlanned = index <= todayOffset;
        final isCompleted = index == 0 || index == 2;
        final hasReflection = index != 0;
        final isGoldenDay = index == 2;
        return DayProgressNode(
          date: date,
          isPlanned: isPlanned,
          isCompleted: isCompleted,
          isGoldenDay: isGoldenDay,
          hasReflection: hasReflection,
        );
      });

      final progress = CoreWeekProgress(
        windowStart: startOfWeek,
        windowEnd: startOfWeek.add(const Duration(days: 6)),
        days: nodes,
      );

      expect(progress.plannedDaysCount, todayOffset + 1);
      expect(progress.completedDaysCount, 2);
      expect(progress.hasGoldenDay, isTrue);
      expect(progress.stats.pendingReflections, 1);
      expect(progress.todayIndex, todayOffset);
      expect(
        progress.progressRatio,
        closeTo(2 / (todayOffset + 1), 0.001),
      );
    });
  });
}
