// lib/features/calendar/widgets/level_map_calendar.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../models/calendar_event.dart';

/// LevelMapCalendar
///
/// Displays the days of a month in a 6x7 grid.
/// Each day shows an icon indicating scheduled, completed or Golden Day
/// events. A small bug mascot slides to the selected day.
class LevelMapCalendar extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDay;
  final List<CalendarEvent> Function(DateTime day) eventLoader;
  final ValueChanged<DateTime> onDaySelected;

  const LevelMapCalendar({
    super.key,
    required this.month,
    required this.selectedDay,
    required this.eventLoader,
    required this.onDaySelected,
  });

  static const scheduledColor = Color(0xFF0055FF);
  static const completedColor = Color(0xFF00CC66);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final startOffset = firstOfMonth.weekday - 1; // Monday=1
    final startDate = firstOfMonth.subtract(Duration(days: startOffset));
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / 7;
        final bugSize = cellWidth * 0.7;

        final cellHeight = constraints.maxHeight / 6;

        final cellHeight = (constraints.maxHeight - bugSize - 8) / 6;

        final aspectRatio = cellWidth / cellHeight;

        final selectedIndex = selectedDay.difference(startDate).inDays;
        final bugRow = selectedIndex ~/ 7;
        final bugCol = selectedIndex % 7;
        final bugLeft = bugCol * cellWidth + (cellWidth - bugSize) / 2;
        final bugTop = bugRow * cellHeight + (cellHeight - bugSize) / 2;

        return SizedBox.expand(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 6 * cellHeight,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: aspectRatio,
                      ),
                    itemCount: 42,
                    itemBuilder: (ctx, i) {
                      final date = startDate.add(Duration(days: i));
                      final inMonth = date.month == month.month;


                      final events = eventLoader(date);
                      final isSelected = _isSameDay(date, selectedDay);

                      final hasGolden = events.any((e) => e.isGoldenDay);
                      final hasCompleted = events.any((e) => e.isCompleted);
                      final completedCount =
                          events.where((e) => e.isCompleted).length;
                      final progress = events.isEmpty
                          ? 0.0
                          : hasGolden
                              ? 1.0
                              : completedCount / events.length;


                      final icon = hasGolden
                          ? Icons.star
                          : hasCompleted
                              ? Icons.check_circle
                              : events.isNotEmpty
                                  ? Icons.schedule
                                  : Icons.circle_outlined;
                      final iconColor = hasGolden
                          ? Colors.amber
                          : hasCompleted
                              ? completedColor
                              : scheduledColor;

                      return GestureDetector(
                        onTap: () => onDaySelected(date),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? scheduledColor.withAlpha((0.2 * 255).round())
                                : null,
                            borderRadius: BorderRadius.circular(4),
                          ),

                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                right: 4,
                                top: 4,
                                bottom: 4,
                                child: Container(
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: scheduledColor.withAlpha(50),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: FractionallySizedBox(
                                      heightFactor: progress,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: progress == 1.0
                                              ? completedColor
                                              : scheduledColor,
                                          borderRadius: const BorderRadius.vertical(
                                            bottom: Radius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: inMonth ? null : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(
                                    icon,
                                    size: math.min(cellWidth, cellHeight) / 3,
                                    color: iconColor,
                                  ),
                                ],
                              ),
                              ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                top: bugTop,
                left: bugLeft,
                child: Image.asset(
                  'assets/images/bug.png',
                  width: bugSize,
                  height: bugSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
