// lib/features/common/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/common/dashboard_route_args.dart';
import 'package:free_base/features/common/state/dashboard_view_model.dart';
import 'package:free_base/features/common/widgets/dashboard_calendar_card.dart';
import 'package:free_base/features/common/widgets/dashboard_header.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/features/training/widgets/session_status_banner.dart';
import 'package:free_base/services/app_routes.dart';
import 'package:free_base/services/training_intent.dart';

/// DashboardScreen
///
/// Startpunkt der App mit Navigation zu Training und Kalender.
class DashboardScreen extends StatefulWidget {
  final DashboardRouteArgs? routeArgs;

  const DashboardScreen({Key? key, this.routeArgs}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _intentHandled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_intentHandled) return;
    _intentHandled = true;
    context.read<SessionNotifier>().refreshScheduleStatus();
    final args = widget.routeArgs;
    if (args != null && args.startTraining) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.goNamed(
          AppRouteNames.training,
          extra: TrainingIntent.start(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionNotifier = context.watch<SessionNotifier>();
    final state = sessionNotifier.state;
    final dashboard = context.watch<DashboardViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          DashboardHeader(
            level: dashboard.currentLevel,
            levelProgress: dashboard.levelProgress,
            xpTotal: dashboard.xpTotal,
            xpToNextLevel: dashboard.xpToNextLevel,
            streakCount: dashboard.streakCount,
            freezeAvailable: dashboard.freezeAvailable,
            dailyXp: dashboard.dailyXp,
            freezeUntil: dashboard.streakFrozenUntil,
          ),
          const SizedBox(height: 16),
          SessionStatusBanner.fromSession(state),
          const SizedBox(height: 16),
          DashboardCalendarCard(
            weekProgress: dashboard.currentWeekProgress,
            onOpenCalendar: () => context.goNamed(AppRouteNames.calendar),
            onReminderTap: () => _handleReminderTap(context, dashboard),
            reminderTime: dashboard.scheduledReminder,
            reminderActive: dashboard.hasScheduledReminder,
          ),
          const SizedBox(height: 24),
          Text(
            'Bleib dran: Jede Einheit bringt dich deinem Ziel ein Stück näher.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.goNamed(
                    AppRouteNames.training,
                    extra: TrainingIntent.start(),
                  ),
                  child: const Text('Training starten'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.goNamed(
                    AppRouteNames.calendar,
                    queryParameters: const {'setReminder': 'true'},
                  ),
                  child: const Text('Nächstes Training planen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleReminderTap(
    BuildContext context,
    DashboardViewModel dashboard,
  ) async {
    if (!dashboard.hasScheduledReminder) {
      await _pickReminderTime(context, dashboard);
      return;
    }

    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Uhrzeit ändern'),
                onTap: () => Navigator.of(sheetContext).pop('change'),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Reminder entfernen'),
                onTap: () => Navigator.of(sheetContext).pop('cancel'),
              ),
            ],
          ),
        );
      },
    );

    if (!context.mounted) {
      return;
    }

    if (action == 'change') {
      await _pickReminderTime(context, dashboard);
    } else if (action == 'cancel') {
      await dashboard.cancelReminder();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder deaktiviert.')),
      );
    }
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    DashboardViewModel dashboard,
  ) async {
    final initialTime = dashboard.scheduledReminder ?? const TimeOfDay(hour: 18, minute: 0);
    final result = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Erinnerung auswählen',
    );
    if (result != null) {
      await dashboard.scheduleReminder(result);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder gesetzt für ${result.format(context)}.'),
        ),
      );
    }
  }
}
