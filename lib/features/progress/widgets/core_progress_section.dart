import 'dart:async';

import 'package:flutter/material.dart';
import 'package:free_base/features/progress/models/week_progress.dart';

/// Callback used when a day node in the progress bar is tapped.
typedef ProgressNodeTapCallback = void Function(DayProgressNode node);

/// Callback used when a day node is long pressed.
typedef ProgressNodeLongPressCallback = FutureOr<void> Function(
  BuildContext context,
  DayProgressNode node,
);

/// Optional hooks that allow consumers to trigger haptics or audio feedback.
class ProgressFeedbackHooks {
  const ProgressFeedbackHooks({
    this.onNodeTapHaptic,
    this.onNodeTapAudio,
    this.onNodeLongPressHaptic,
    this.onNodeLongPressAudio,
    this.onStartTrainingHaptic,
    this.onStartTrainingAudio,
    this.onStartNextWeekHaptic,
    this.onStartNextWeekAudio,
    this.onOpenReflectionHaptic,
    this.onOpenReflectionAudio,
  });

  final FutureOr<void> Function(DayProgressNode node)? onNodeTapHaptic;
  final FutureOr<void> Function(DayProgressNode node)? onNodeTapAudio;
  final FutureOr<void> Function(DayProgressNode node)? onNodeLongPressHaptic;
  final FutureOr<void> Function(DayProgressNode node)? onNodeLongPressAudio;
  final FutureOr<void> Function()? onStartTrainingHaptic;
  final FutureOr<void> Function()? onStartTrainingAudio;
  final FutureOr<void> Function()? onStartNextWeekHaptic;
  final FutureOr<void> Function()? onStartNextWeekAudio;
  final FutureOr<void> Function()? onOpenReflectionHaptic;
  final FutureOr<void> Function()? onOpenReflectionAudio;
}

/// High level section combining the progress widgets for the dashboard.
class CoreProgressSection extends StatelessWidget {
  const CoreProgressSection({
    super.key,
    required this.progress,
    this.onNodeTap,
    this.onNodeLongPress,
    this.onStartTraining,
    this.onStartNextWeek,
    this.onOpenReflection,
    this.feedbackHooks,
  });

  final CoreWeekProgress progress;
  final ProgressNodeTapCallback? onNodeTap;
  final ProgressNodeLongPressCallback? onNodeLongPress;
  final VoidCallback? onStartTraining;
  final VoidCallback? onStartNextWeek;
  final VoidCallback? onOpenReflection;
  final ProgressFeedbackHooks? feedbackHooks;

  @override
  Widget build(BuildContext context) {
    final stats = progress.stats;
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CoreHeader(progress: progress),
        const SizedBox(height: 16),
        WeekProgressBar(
          progress: progress,
          onNodeTap: onNodeTap,
          onNodeLongPress: onNodeLongPress,
          feedbackHooks: feedbackHooks,
        ),
        const SizedBox(height: 16),
        StatsStrip(stats: stats),
        if (onStartTraining != null || onStartNextWeek != null) ...[
          const SizedBox(height: 16),
          TrainingCta(
            onStartTraining: onStartTraining,
            onStartNextWeek: onStartNextWeek,
            feedbackHooks: feedbackHooks,
          ),
        ],
        if (stats.hasPendingReflections && onOpenReflection != null) ...[
          const SizedBox(height: 16),
          ReflectionCard(
            pendingReflections: stats.pendingReflections,
            onOpenReflection: onOpenReflection!,
            feedbackHooks: feedbackHooks,
            disableAnimations: disableAnimations,
          ),
        ],
      ],
    );
  }
}

/// Header describing the current tracked week.
class CoreHeader extends StatelessWidget {
  const CoreHeader({
    super.key,
    required this.progress,
  });

  final CoreWeekProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final ratio = progress.progressRatio.clamp(0.0, 1.0).toDouble();

    final periodLabel =
        '${_formatDate(progress.windowStart)} – ${_formatDate(progress.windowEnd)}';

    final goldenDayChip = progress.hasGoldenDay
        ? Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: AnimatedScale(
              scale: disableAnimations ? 1.0 : 1.05,
              duration:
                  disableAnimations ? Duration.zero : const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: Chip(
                avatar: Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                label: Text(
                  'Golden Day gesichtet',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                backgroundColor: theme.colorScheme.secondaryContainer,
              ),
            ),
          )
        : const SizedBox.shrink();

    return Semantics(
      label: 'Wochenfortschritt',
      value: 'Fortschritt ${(ratio * 100).round()} Prozent',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Diese Woche',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              goldenDayChip,
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            key: ValueKey(ratio),
            tween: Tween<double>(begin: 0.0, end: ratio),
            duration:
                disableAnimations ? Duration.zero : const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 12,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$periodLabel · ${(value * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}

/// Visualises the day progress nodes for a tracked week.
class WeekProgressBar extends StatefulWidget {
  const WeekProgressBar({
    super.key,
    required this.progress,
    this.onNodeTap,
    this.onNodeLongPress,
    this.feedbackHooks,
  });

  final CoreWeekProgress progress;
  final ProgressNodeTapCallback? onNodeTap;
  final ProgressNodeLongPressCallback? onNodeLongPress;
  final ProgressFeedbackHooks? feedbackHooks;

  @override
  State<WeekProgressBar> createState() => _WeekProgressBarState();
}

class _WeekProgressBarState extends State<WeekProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _animationsDisabled = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disable = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_animationsDisabled != disable) {
      _animationsDisabled = disable;
      if (disable) {
        _pulseController.stop();
      } else {
        _pulseController.repeat(reverse: true);
      }
    } else if (!disable && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        for (final node in widget.progress.days)
          Expanded(
            child: _buildDayNode(context, theme, node),
          ),
      ],
    );
  }

  Widget _buildDayNode(
    BuildContext context,
    ThemeData theme,
    DayProgressNode node,
  ) {
    final bool isToday = node.isToday;
    final bool isCompleted = node.isCompleted;
    final bool isPlanned = node.isPlanned;
    final bool highlight = node.requiresReflection;

    final Color completedColor = theme.colorScheme.primary;
    final Color plannedColor = theme.colorScheme.primary.withOpacity(0.35);
    final Color neutralColor = theme.colorScheme.surfaceVariant;
    final Color outlineColor = theme.colorScheme.outlineVariant;

    const double size = 56.0;

    final semanticsLabel = StringBuffer()
      ..write('Tag ${_formatDate(node.date)}')
      ..write(isToday ? ', heute' : '')
      ..write(isPlanned ? ', Training geplant' : ', kein Training geplant')
      ..write(isCompleted ? ', abgeschlossen' : '')
      ..write(node.hasReflection ? ', Reflexion vorhanden' : '');

    final bool disableAnimations = _animationsDisabled;

    return Semantics(
      container: true,
      label: semanticsLabel.toString(),
      hint: widget.onNodeTap != null
          ? 'Tippen für Details'
          : widget.onNodeLongPress != null
              ? 'Gedrückt halten für Details'
              : null,
      button: widget.onNodeTap != null || widget.onNodeLongPress != null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: InkWell(
          onTap: widget.onNodeTap != null
              ? () => _handleTap(context, node)
              : null,
          onLongPress: widget.onNodeLongPress != null
              ? () => _handleLongPress(context, node)
              : null,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size + 32.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      final glowStrength = highlight && !disableAnimations
                          ? 0.35 + 0.45 * _pulseAnimation.value
                          : 0.0;
                      final List<BoxShadow> shadows;
                      if (glowStrength > 0.0) {
                        shadows = [
                          BoxShadow(
                            color: theme.colorScheme.tertiary
                                .withOpacity(glowStrength),
                            blurRadius: 16.0 + 12.0 * glowStrength,
                            spreadRadius: 1.0 + 4.0 * glowStrength,
                          ),
                        ];
                      } else {
                        shadows = const [];
                      }

                      final Color backgroundColor = isCompleted
                          ? completedColor
                          : isPlanned
                              ? plannedColor
                              : neutralColor;

                      return AnimatedScale(
                        duration: disableAnimations
                            ? Duration.zero
                            : const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        scale: isToday && !disableAnimations ? 1.05 : 1.0,
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: outlineColor,
                              width: 1.0,
                            ),
                            boxShadow: shadows,
                          ),
                          alignment: Alignment.center,
                          child: TweenAnimationBuilder<double>(
                            key: ValueKey(
                              '${node.date.toIso8601String()}-${isCompleted ? 'done' : isPlanned ? 'planned' : 'idle'}',
                            ),
                            tween: Tween<double>(
                              begin: isCompleted ? 0.4 : 0.0,
                              end:
                                  isCompleted ? 1.0 : (isPlanned ? 0.35 : 0.0),
                            ),
                            duration: disableAnimations
                                ? Duration.zero
                                : const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              final Color iconColor = isCompleted
                                  ? theme.colorScheme.onPrimary
                                  : isPlanned
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline;
                              return Icon(
                                isCompleted
                                    ? Icons.check_circle
                                    : (isPlanned
                                        ? Icons.calendar_today
                                        : Icons.remove_circle_outline),
                                color: iconColor
                                    .withOpacity(value.clamp(0.35, 1.0).toDouble()),
                                size: 20.0 + 6.0 * value,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                ExcludeSemantics(
                  child: Text(
                    _weekdayLabel(node.date),
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, DayProgressNode node) {
    widget.feedbackHooks?.onNodeTapHaptic?.call(node);
    widget.feedbackHooks?.onNodeTapAudio?.call(node);
    widget.onNodeTap?.call(node);
  }

  Future<void> _handleLongPress(BuildContext context, DayProgressNode node) async {
    widget.feedbackHooks?.onNodeLongPressHaptic?.call(node);
    widget.feedbackHooks?.onNodeLongPressAudio?.call(node);
    await widget.onNodeLongPress?.call(context, node);
  }

  String _weekdayLabel(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Mo';
      case DateTime.tuesday:
        return 'Di';
      case DateTime.wednesday:
        return 'Mi';
      case DateTime.thursday:
        return 'Do';
      case DateTime.friday:
        return 'Fr';
      case DateTime.saturday:
        return 'Sa';
      case DateTime.sunday:
        return 'So';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.';
  }
}

/// Displays aggregated statistics of the tracked week.
class StatsStrip extends StatelessWidget {
  const StatsStrip({
    super.key,
    required this.stats,
  });

  final WeekProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildTile(String label, String value, IconData icon) {
      return Expanded(
        child: Semantics(
          label: '$label: $value',
          child: Container(
            height: 72,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: theme.textTheme.labelSmall),
                      Text(
                        value,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildTile(
          'Geplant',
          stats.plannedDays.toString(),
          Icons.event_available,
        ),
        const SizedBox(width: 12),
        buildTile(
          'Abgeschlossen',
          stats.completedDays.toString(),
          Icons.check_circle_outline,
        ),
        const SizedBox(width: 12),
        buildTile(
          'Reflexion offen',
          stats.pendingReflections.toString(),
          Icons.psychology_alt_outlined,
        ),
      ],
    );
  }
}

/// Provides actions to start a training or prepare the next week.
class TrainingCta extends StatelessWidget {
  const TrainingCta({
    super.key,
    this.onStartTraining,
    this.onStartNextWeek,
    this.feedbackHooks,
  });

  final VoidCallback? onStartTraining;
  final VoidCallback? onStartNextWeek;
  final ProgressFeedbackHooks? feedbackHooks;

  @override
  Widget build(BuildContext context) {
    final bool hasStartTraining = onStartTraining != null;
    final bool hasStartNextWeek = onStartNextWeek != null;

    if (!hasStartTraining && !hasStartNextWeek) {
      return const SizedBox.shrink();
    }

    return Semantics(
      container: true,
      label: 'Training Aktionen',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          if (hasStartTraining)
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 160, minHeight: 48),
              child: FilledButton.icon(
                onPressed: () {
                  feedbackHooks?.onStartTrainingHaptic?.call();
                  feedbackHooks?.onStartTrainingAudio?.call();
                  onStartTraining?.call();
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Training starten'),
              ),
            ),
          if (hasStartNextWeek)
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 160, minHeight: 48),
              child: OutlinedButton.icon(
                onPressed: () {
                  feedbackHooks?.onStartNextWeekHaptic?.call();
                  feedbackHooks?.onStartNextWeekAudio?.call();
                  onStartNextWeek?.call();
                },
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text('Nächste Woche planen'),
              ),
            ),
        ],
      ),
    );
  }
}

/// Card highlighting pending reflections.
class ReflectionCard extends StatelessWidget {
  const ReflectionCard({
    super.key,
    required this.pendingReflections,
    required this.onOpenReflection,
    this.feedbackHooks,
    this.disableAnimations = false,
  });

  final int pendingReflections;
  final VoidCallback onOpenReflection;
  final ProgressFeedbackHooks? feedbackHooks;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = pendingReflections == 1
        ? 'Eine Reflexion ausstehend'
        : '$pendingReflections Reflexionen ausstehend';

    return Semantics(
      label: label,
      hint: 'Tippen um Reflexion zu öffnen',
      button: true,
      child: AnimatedScale(
        scale: disableAnimations ? 1.0 : 1.02,
        duration:
            disableAnimations ? Duration.zero : const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        child: Card(
          color: theme.colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.self_improvement,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '$label. Jetzt nachbereiten?',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints:
                      const BoxConstraints(minHeight: 48, minWidth: 48),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.onSecondaryContainer,
                      foregroundColor: theme.colorScheme.secondaryContainer,
                    ),
                    onPressed: () {
                      feedbackHooks?.onOpenReflectionHaptic?.call();
                      feedbackHooks?.onOpenReflectionAudio?.call();
                      onOpenReflection();
                    },
                    child: const Text('Öffnen'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Convenience helper to display a detail bottom sheet for a day node.
Future<void> showProgressNodeDetailsBottomSheet({
  required BuildContext context,
  required DayProgressNode node,
}) {
  final theme = Theme.of(context);
  final dateLabel =
      '${node.date.day.toString().padLeft(2, '0')}.${node.date.month.toString().padLeft(2, '0')}.${node.date.year}';

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final textTheme = theme.textTheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Details für $dateLabel', style: textTheme.titleLarge),
              const SizedBox(height: 16),
              _DetailRow(
                icon: Icons.event_available,
                label: 'Training geplant',
                value: node.isPlanned ? 'Ja' : 'Nein',
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.check_circle_outline,
                label: 'Abgeschlossen',
                value: node.isCompleted ? 'Ja' : 'Nein',
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.auto_awesome,
                label: 'Golden Day',
                value: node.isGoldenDay ? 'Markiert' : 'Nicht markiert',
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.psychology_alt_outlined,
                label: 'Reflexion',
                value: node.hasReflection ? 'Vorhanden' : 'Fehlt',
              ),
              if (node.requiresReflection) ...[
                const SizedBox(height: 24),
                Text(
                  'Tipp: Reflexion noch ausstehend.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$label: $value',
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
