// lib/features/common/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/common/dashboard_route_args.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SessionStatusBanner.fromSession(state),
            const SizedBox(height: 24),
            Text(
              'Willkommen im Dashboard!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Behalte deinen Trainingsfortschritt im Blick und starte deine nächste Einheit, wenn du bereit bist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.goNamed(
                  AppRouteNames.training,
                ),
                child: const Text('Training starten'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.goNamed(AppRouteNames.calendar),
                child: const Text('Zum Kalender'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
