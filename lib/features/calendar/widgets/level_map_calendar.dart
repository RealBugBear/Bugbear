// lib/features/calendar/widgets/level_map_calendar.dart

import 'package:flutter/material.dart';

import '../models/calendar_event.dart';

/// LevelMapCalendar
///
/// Displays the days of a month in a horizontally scrollable row.
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
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth > 600 ? 70.0 : 50.0;
        final bugSize = cellSize * 0.7;
        final selectedIndex = selectedDay.day - 1;
        final bugLeft = selectedIndex * cellSize + (cellSize - bugSize) / 2;

        return SizedBox(
          height: cellSize + bugSize + 16,
          child: Stack(
            children: [
              Positioned(
                top: bugSize + 8,
                left: 0,
                right: 0,
                bottom: 0,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(daysInMonth, (i) {
                      final date = DateTime(month.year, month.month, i + 1);
                      final events = eventLoader(date);
                      final isSelected = _isSameDay(date, selectedDay);

                      bool hasGolden = events.any((e) => e.isGoldenDay);
                      bool hasCompleted = events.any((e) => e.isCompleted);
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
                          width: cellSize,
                          height: cellSize,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? scheduledColor.withOpacity(0.2)
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Icon(icon, size: cellSize / 3, color: iconColor),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                top: 0,
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
