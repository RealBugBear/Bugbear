import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:free_base/features/training/models/session_state.dart';

enum SessionStatusBannerState { planned, inProgress, overdue }

class SessionStatusBanner extends StatelessWidget {
  final SessionStatusBannerState status;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const SessionStatusBanner({
    super.key,
    required this.status,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  factory SessionStatusBanner.fromSession(SessionState state) {
    final resolved = _resolveStatus(state);
    return SessionStatusBanner(
      status: resolved,
      title: _buildTitle(resolved),
      subtitle: _buildSubtitle(resolved, state),
    );
  }

  static SessionStatusBannerState _resolveStatus(SessionState state) {
    if (state.status == SessionStatus.inProgress && !state.isPaused) {
      return SessionStatusBannerState.inProgress;
    }
    if (state.status == SessionStatus.inProgress && state.completedReps > 0) {
      return SessionStatusBannerState.inProgress;
    }
    if (state.status == SessionStatus.overdue) {
      return SessionStatusBannerState.overdue;
    }
    if (state.status == SessionStatus.planned) {
      if (state.plannedFor != null &&
          DateTime.now().isAfter(state.plannedFor!)) {
        return SessionStatusBannerState.overdue;
      }
      return SessionStatusBannerState.planned;
    }
    if (state.status == SessionStatus.completed) {
      return SessionStatusBannerState.planned;
    }
    return SessionStatusBannerState.planned;
  }

  static String _buildTitle(SessionStatusBannerState status) {
    switch (status) {
      case SessionStatusBannerState.inProgress:
        return 'Session in Bearbeitung';
      case SessionStatusBannerState.overdue:
        return 'Session überfällig';
      case SessionStatusBannerState.planned:
        return 'Session geplant';
    }
  }

  static String? _buildSubtitle(
      SessionStatusBannerState status, SessionState state) {
    final plannedFor = state.plannedFor;
    switch (status) {
      case SessionStatusBannerState.inProgress:
        return state.isPaused
            ? 'Du hast pausiert. Setze fort, wenn du bereit bist.'
            : 'Weiter so! Beende deine aktuelle Session.';
      case SessionStatusBannerState.overdue:
        if (plannedFor != null) {
          return 'Geplant für ${DateFormat.yMMMMd().format(plannedFor)} um '
              '${DateFormat.Hm().format(plannedFor)}';
        }
        return 'Starte deine Session, um wieder im Plan zu sein.';
      case SessionStatusBannerState.planned:
        if (plannedFor != null) {
          if (plannedFor.isAfter(DateTime.now())) {
            return 'Geplant für ${DateFormat.yMMMMd().format(plannedFor)}';
          }
          return 'Bereit sobald du startest.';
        }
        return 'Plane deine nächste Session, wenn es für dich passt.';
    }
  }

  Color _backgroundColor(BuildContext context) {
    switch (status) {
      case SessionStatusBannerState.inProgress:
        return Theme.of(context).colorScheme.primary.withAlpha(31);
      case SessionStatusBannerState.overdue:
        return Theme.of(context).colorScheme.error.withAlpha(31);
      case SessionStatusBannerState.planned:
        return Theme.of(context).colorScheme.secondary.withAlpha(31);
    }
  }

  Color _borderColor(BuildContext context) {
    switch (status) {
      case SessionStatusBannerState.inProgress:
        return Theme.of(context).colorScheme.primary;
      case SessionStatusBannerState.overdue:
        return Theme.of(context).colorScheme.error;
      case SessionStatusBannerState.planned:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  IconData _icon() {
    switch (status) {
      case SessionStatusBannerState.inProgress:
        return Icons.play_circle_fill;
      case SessionStatusBannerState.overdue:
        return Icons.warning_amber_rounded;
      case SessionStatusBannerState.planned:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          _icon(),
          color: _borderColor(context),
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _backgroundColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor(context)),
          ),
          child: content,
        ),
      ),
    );
  }
}
