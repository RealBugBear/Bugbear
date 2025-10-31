// lib/features/common/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/common/dashboard_route_args.dart';
import 'package:free_base/features/common/state/dashboard_view_model.dart';
import 'package:free_base/features/common/widgets/dashboard_header.dart';
import 'package:free_base/features/progress/models/week_progress.dart';
import 'package:free_base/features/progress/widgets/core_progress_section.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: [
          Selector<DashboardViewModel, _DashboardHeaderData>(
            selector: (_, vm) => _DashboardHeaderData(
              level: vm.currentLevel,
              levelProgress: vm.levelProgress,
              xpTotal: vm.xpTotal,
              xpToNextLevel: vm.xpToNextLevel,
              streakCount: vm.streakCount,
              freezeAvailable: vm.freezeAvailable,
              dailyXp: vm.dailyXp,
              freezeUntil: vm.streakFrozenUntil,
            ),
            builder: (context, data, _) {
              return DashboardHeader(
                level: data.level,
                levelProgress: data.levelProgress,
                xpTotal: data.xpTotal,
                xpToNextLevel: data.xpToNextLevel,
                streakCount: data.streakCount,
                freezeAvailable: data.freezeAvailable,
                dailyXp: data.dailyXp,
                freezeUntil: data.freezeUntil,
              );
            },
          ),
          const SizedBox(height: 16),
          SessionStatusBanner.fromSession(state),
          const SizedBox(height: 24),
          Selector<DashboardViewModel, CoreWeekProgress>(
            selector: (_, vm) => vm.currentWeekProgress,
            builder: (context, progress, _) {
              final stats = progress.stats;
              return CoreProgressSection(
                progress: progress,
                onStartTraining: () => _startTraining(context),
                onStartNextWeek: () => _startNextWeek(context),
                onOpenReflection: stats.hasPendingReflections
                    ? () => _openReflection(context)
                    : null,
              );
            },
          ),
          const SizedBox(height: 24),
          Selector<DashboardViewModel, _ReminderStatus>(
            selector: (_, vm) => _ReminderStatus(
              hasScheduledReminder: vm.hasScheduledReminder,
              scheduledReminder: vm.scheduledReminder,
            ),
            builder: (context, reminder, _) {
              return _ReminderCard(
                active: reminder.hasScheduledReminder,
                time: reminder.scheduledReminder,
                onTap: () => _handleReminderTap(
                  context,
                  context.read<DashboardViewModel>(),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Bleib dran: Jede Einheit bringt dich deinem Ziel ein Stück näher.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  void _startTraining(BuildContext context) {
    context.goNamed(
      AppRouteNames.training,
      extra: TrainingIntent.start(),
    );
  }

  Future<void> _startNextWeek(BuildContext context) async {
    final dashboard = context.read<DashboardViewModel>();
    await dashboard.startNextWeek();
    if (!mounted) return;
    context.goNamed(AppRouteNames.calendar);
  }

  Future<void> _openReflection(BuildContext context) async {
    final dashboard = context.read<DashboardViewModel>();
    final opened = await dashboard.openReflection();
    if (!mounted) return;
    if (opened) {
      context.goNamed(AppRouteNames.calendar);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keine Reflexionen offen.')),
      );
    }
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

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.active,
    required this.time,
    required this.onTap,
  });

  final bool active;
  final TimeOfDay? time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = active ? Icons.alarm_on : Icons.alarm_add;
    final title = active ? 'Reminder aktiv' : 'Reminder setzen';
    final timeLabel = time?.format(context);
    final subtitle = active
        ? (timeLabel != null && timeLabel.isNotEmpty
            ? 'Tägliche Erinnerung um $timeLabel'
            : 'Tägliche Erinnerung aktiv')
        : 'Plane eine tägliche Trainings-Erinnerung.';

    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _DashboardHeaderData {
  const _DashboardHeaderData({
    required this.level,
    required this.levelProgress,
    required this.xpTotal,
    required this.xpToNextLevel,
    required this.streakCount,
    required this.freezeAvailable,
    required this.dailyXp,
    required this.freezeUntil,
  });

  final int level;
  final double levelProgress;
  final int xpTotal;
  final int xpToNextLevel;
  final int streakCount;
  final bool freezeAvailable;
  final int dailyXp;
  final DateTime? freezeUntil;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _DashboardHeaderData &&
        other.level == level &&
        other.levelProgress == levelProgress &&
        other.xpTotal == xpTotal &&
        other.xpToNextLevel == xpToNextLevel &&
        other.streakCount == streakCount &&
        other.freezeAvailable == freezeAvailable &&
        other.dailyXp == dailyXp &&
        other.freezeUntil == freezeUntil;
  }

  @override
  int get hashCode => Object.hash(
        level,
        levelProgress,
        xpTotal,
        xpToNextLevel,
        streakCount,
        freezeAvailable,
        dailyXp,
        freezeUntil,
      );
}

class _ReminderStatus {
  const _ReminderStatus({
    required this.hasScheduledReminder,
    required this.scheduledReminder,
  });

  final bool hasScheduledReminder;
  final TimeOfDay? scheduledReminder;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ReminderStatus &&
        other.hasScheduledReminder == hasScheduledReminder &&
        other.scheduledReminder == scheduledReminder;
  }

  @override
  int get hashCode => Object.hash(
        hasScheduledReminder,
        scheduledReminder,
      );
}
