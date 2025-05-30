// lib/features/calendar/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/calendar_event.dart';
import '../dialogs/edit_training_day_dialog.dart';
import '../notifier/calendar_notifier.dart';
import '../services/calendar_service.dart';

/// CalendarScreen
///
/// Zeigt einen Monatskalender mit:
/// - pulsierendem Rahmen am heutigen Tag
/// - farbcodierten Markern
/// - ListView der Events am ausgewählten Tag
/// - Edit-Dialog beim Tap auf einen Event
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CalendarNotifier>(
      create: (ctx) {
        final service = ctx.read<CalendarService>();
        final notifier = CalendarNotifier(service);
        notifier.loadMonth(DateTime.now());
        return notifier;
      },
      child: const _CalendarScreenContent(),
    );
  }
}

class _CalendarScreenContent extends StatefulWidget {
  const _CalendarScreenContent({Key? key}) : super(key: key);

  @override
  State<_CalendarScreenContent> createState() =>
      _CalendarScreenContentState();
}

class _CalendarScreenContentState extends State<_CalendarScreenContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  static const scheduledColor = Color(0xFF0055FF);
  static const completedColor = Color(0xFF00CC66);
  static const missedColor = Color(0xFFFFCC00);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.2).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<CalendarNotifier>();
    final today = DateTime.now();
    final focusedDay = notifier.focusedDay;
    final selectedDay = notifier.selectedDay;
    final dayEvents = notifier.eventsForSelectedDay;

    return Scaffold(
      appBar: AppBar(title: const Text('Dein Trainingskalender')),
      body: Column(
        children: [
          TableCalendar<CalendarEvent>(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (d) => isSameDay(d, selectedDay),
            onDaySelected: (sel, focus) => notifier.selectDay(sel),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(),
            ),
            eventLoader: notifier.eventsForDay,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (ctx, date, _) =>
                  _buildDayCell(date, date, today),
              todayBuilder: (ctx, date, _) => ScaleTransition(
                scale: _scale,
                child: _buildDayCell(date, date, today, isToday: true),
              ),
              selectedBuilder: (ctx, date, _) {
                final cell = _buildDayCell(date, date, today, isSelected: true);
                return isSameDay(date, today)
                    ? ScaleTransition(scale: _scale, child: cell)
                    : cell;
              },
              markerBuilder: (ctx, date, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events.map((ev) {
                    final color = ev.isCompleted
                        ? completedColor
                        : date.isBefore(DateTime(today.year, today.month, today.day))
                            ? missedColor
                            : scheduledColor;
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: dayEvents.isEmpty
                ? const Center(child: Text('Keine Einträge an diesem Tag'))
                : ListView.builder(
                    itemCount: dayEvents.length,
                    itemBuilder: (ctx, i) {
                      final ev = dayEvents[i];
                      return ListTile(
                        title: Text(ev.title),
                        leading: Icon(
                          ev.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color:
                              ev.isCompleted ? completedColor : scheduledColor,
                        ),
                        onTap: () async {
                          final updated = await showDialog<CalendarEvent>(
                            context: context,
                            builder: (_) =>
                                EditTrainingDayDialog(event: ev),
                          );
                          if (updated != null) {
                            await notifier
                                .loadMonth(notifier.focusedDay);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime date, DateTime cellDate, DateTime today,
      {bool isToday = false, bool isSelected = false}) {
    final selectedDay = context.read<CalendarNotifier>().selectedDay;
    final sel = isSameDay(cellDate, selectedDay);
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: sel ? scheduledColor.withOpacity(0.2) : null,
        border: isToday ? Border.all(color: scheduledColor, width: 2) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        date.day.toString(),
        style: TextStyle(
          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          color: sel ? scheduledColor : null,
        ),
      ),
    );
  }
}
