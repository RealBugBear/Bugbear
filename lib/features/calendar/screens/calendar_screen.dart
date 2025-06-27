// lib/features/calendar/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/level_map_calendar.dart';

import '../models/calendar_event.dart';
import '../dialogs/edit_training_day_dialog.dart';
import '../notifier/calendar_notifier.dart';
import '../services/calendar_service.dart';
import 'package:bugbear_app/widgets/app_drawer.dart';

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

class _CalendarScreenContentState extends State<_CalendarScreenContent> {

  static const scheduledColor = Color(0xFF0055FF);
  static const completedColor = Color(0xFF00CC66);


  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<CalendarNotifier>();
    final focusedDay = notifier.focusedDay;
    final selectedDay = notifier.selectedDay;
    final dayEvents = notifier.eventsForSelectedDay;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Dein Trainingskalender')),
      body: Column(
        children: [
          LevelMapCalendar(
            month: focusedDay,
            selectedDay: selectedDay,
            eventLoader: notifier.eventsForDay,
            onDaySelected: notifier.selectDay,
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

  // no custom day cell needed with LevelMapCalendar
}
