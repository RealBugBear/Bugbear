import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/training/services/sync_service.dart';

class SessionSyncListener extends StatefulWidget {
  final Widget child;
  final GlobalKey<ScaffoldMessengerState> messengerKey;

  const SessionSyncListener({
    super.key,
    required this.child,
    required this.messengerKey,
  });

  @override
  State<SessionSyncListener> createState() => _SessionSyncListenerState();
}

class _SessionSyncListenerState extends State<SessionSyncListener> {
  StreamSubscription<SyncStatusEvent>? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription?.cancel();
    final syncService = context.read<SyncService>();
    _subscription = syncService.statusStream.listen(_handleEvent);
  }

  void _handleEvent(SyncStatusEvent event) {
    final messenger = widget.messengerKey.currentState;
    if (messenger == null) {
      return;
    }
    final theme = messenger.context.theme;
    final isSuccess = event.success;
    final backgroundColor = isSuccess
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.errorContainer;
    final icon = isSuccess ? Icons.cloud_done : Icons.cloud_off;
    final textColor = isSuccess
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onErrorContainer;
    final message = isSuccess
        ? 'Session erfolgreich synchronisiert.'
        : 'Synchronisation fehlgeschlagen. Versuche es später erneut.';

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

extension on BuildContext {
  ThemeData get theme => Theme.of(this);
}
