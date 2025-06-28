// lib/features/calendar/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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

/// - Einträgen über Popup-Dialog

/// - Einträgen über BottomSheet
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

  static const _initialPage = 1000;
  late final PageController _pageController;
  late final DateTime _baseMonth;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    _baseMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  int _monthDiff(DateTime a, DateTime b) =>
      (a.year - b.year) * 12 + a.month - b.month;

  int _indexForMonth(DateTime month) =>
      _initialPage + _monthDiff(month, _baseMonth);

  DateTime _monthForIndex(int index) {
    final diff = index - _initialPage;
    return DateTime(_baseMonth.year, _baseMonth.month + diff, 1);
  }

  void _onPageChanged(int page) {
    context.read<CalendarNotifier>().loadMonth(_monthForIndex(page));
  }


  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<CalendarNotifier>();
    final focusedDay = notifier.focusedDay;
    final selectedDay = notifier.selectedDay;

    final targetPage = _indexForMonth(focusedDay);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != targetPage) {
        _pageController.jumpToPage(targetPage);
      }
    });

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Dein Trainingskalender')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                for (final label in ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'])
                  Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              pageSnapping: false,
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final month = _monthForIndex(index);
                final isSelectedMonth =
                    month.year == selectedDay.year && month.month == selectedDay.month;
                final isTodayMonth =
                    month.year == DateTime.now().year && month.month == DateTime.now().month;
                final day = isSelectedMonth
                    ? selectedDay
                    : DateTime(month.year, month.month, 1);
                final monthName = DateFormat.MMMM().format(month);
                return Stack(
                  children: [
                    Positioned.fill(
                      child: LevelMapCalendar(
                        month: month,
                        selectedDay: day,
                        showBug: isSelectedMonth,
                        showSelectedHighlight: isSelectedMonth,
                        showTodayHighlight: isTodayMonth,
                        eventLoader: notifier.eventsForDay,
                        onDaySelected: _onDaySelected,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          width: 48,
                          color: Colors.blueGrey.shade50,
                          alignment: Alignment.center,
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Text(
                              monthName,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.comicNeue(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _onDaySelected(DateTime day) async {
    final notifier = context.read<CalendarNotifier>();
    notifier.selectDay(day);
    await showDialog(
      context: context,
      builder: (sheetCtx) {
        final events = notifier.eventsForDay(day);
        if (events.isEmpty) {
          final completed = notifier.dayIsCompleted(day);
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Keine Eintr\u00E4ge an diesem Tag'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      notifier.toggleDayCompleted(day);
                    },
                    icon: Icon(
                      completed ? Icons.undo : Icons.check,
                      color: completed ? scheduledColor : completedColor,
                    ),
                    label: Text(
                      completed
                          ? 'Als nicht erledigt markieren'
                          : 'Training erledigt',
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(sheetCtx).size.height * 0.2,
            horizontal: 24,
          ),
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (ctx, i) {
              final ev = events[i];
              return ListTile(
                title: Text(ev.title),
                leading: Icon(
                  ev.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: ev.isCompleted ? completedColor : scheduledColor,
                ),
                trailing: IconButton(
                  icon: Icon(
                    ev.isCompleted ? Icons.undo : Icons.check,
                    color: ev.isCompleted ? scheduledColor : completedColor,
                  ),
                  onPressed: () {
                    context.read<CalendarNotifier>().toggleCompleted(ev);
                  },
                ),
                onTap: () async {
                  final updated = await showDialog<CalendarEvent>(
                    context: context,
                    builder: (_) => EditTrainingDayDialog(event: ev),
                  );
                  if (updated != null) {
                    await notifier.loadMonth(notifier.focusedDay);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }


  // no custom day cell needed with LevelMapCalendar
}
