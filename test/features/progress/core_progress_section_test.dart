import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:free_base/features/progress/models/week_progress.dart';
import 'package:free_base/features/progress/widgets/core_progress_section.dart';

CoreWeekProgress _buildWeekProgress({required bool includePendingReflection}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final startOfWeek = today.subtract(
    Duration(days: today.weekday - DateTime.monday),
  );
  final todayOffset = today.difference(startOfWeek).inDays;

  final nodes = List<DayProgressNode>.generate(7, (index) {
    final date = startOfWeek.add(Duration(days: index));
    final isPlanned = index <= todayOffset;
    final isCompleted = index == 0 || index == todayOffset;
    final hasReflection = includePendingReflection && index == 0 ? false : true;
    final isGoldenDay = index == 0;
    return DayProgressNode(
      date: date,
      isPlanned: isPlanned,
      isCompleted: isCompleted,
      isGoldenDay: isGoldenDay,
      hasReflection: hasReflection,
    );
  });

  return CoreWeekProgress(
    windowStart: startOfWeek,
    windowEnd: startOfWeek.add(const Duration(days: 6)),
    days: nodes,
  );
}

void main() {
  Widget _wrapWithMaterial(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  testWidgets('shows pending reflection callout when a reflection is missing',
      (tester) async {
    final progress =
        _buildWeekProgress(includePendingReflection: true);

    await tester.pumpWidget(
      _wrapWithMaterial(
        CoreProgressSection(
          progress: progress,
          onOpenReflection: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Golden Day gesichtet'), findsOneWidget);
    expect(
      find.text('Eine Reflexion ausstehend. Jetzt nachbereiten?'),
      findsOneWidget,
    );
  });

  testWidgets('hides reflection callout when all reflections are completed',
      (tester) async {
    final progress =
        _buildWeekProgress(includePendingReflection: false);

    await tester.pumpWidget(
      _wrapWithMaterial(
        CoreProgressSection(
          progress: progress,
          onOpenReflection: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Eine Reflexion ausstehend. Jetzt nachbereiten?'),
        findsNothing);
  });
}
