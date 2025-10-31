import 'package:flutter/material.dart';
import 'package:free_base/features/common/state/dashboard_view_model.dart';

class DashboardCalendarCard extends StatelessWidget {
  final CalendarWeekSummary summary;
  final VoidCallback onOpenCalendar;
  final VoidCallback onReminderTap;
  final TimeOfDay? reminderTime;
  final bool reminderActive;

  const DashboardCalendarCard({
    super.key,
    required this.summary,
    required this.onOpenCalendar,
    required this.onReminderTap,
    required this.reminderTime,
    required this.reminderActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryStyle = theme.textTheme.bodyMedium;
    final plannedDays = summary.plannedDays;
    final completedDays = summary.completedDays;
    final completionText = plannedDays == 0
        ? 'Noch keine Trainings geplant'
        : '$completedDays von $plannedDays Tagen abgeschlossen';

    final reminderLabel = reminderActive
        ? 'Reminder: ${reminderTime?.format(context) ?? ''}'
        : 'Erinnerung setzen';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Kalender Woche',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (summary.hasGoldenDay)
                  Chip(
                    avatar: const Icon(Icons.bug_report_outlined),
                    label: const Text('Golden Day in Sicht'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: summary.completionRate.clamp(0, 1),
            ),
            const SizedBox(height: 8),
            Text(completionText, style: secondaryStyle),
            const SizedBox(height: 8),
            Text(
              'Zeitraum: ${_formatDate(summary.weekStart)} - ${_formatDate(summary.weekEnd)}',
              style: secondaryStyle,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.start,
              children: [
                FilledButton.icon(
                  onPressed: onOpenCalendar,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: const Text('Kalender öffnen'),
                ),
                OutlinedButton.icon(
                  onPressed: onReminderTap,
                  icon: const Icon(Icons.alarm),
                  label: Text(reminderLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';
}
