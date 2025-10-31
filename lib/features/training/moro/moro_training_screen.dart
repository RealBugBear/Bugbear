import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:free_base/features/training/widgets/session_completion_dialog.dart';
import 'package:free_base/services/app_routes.dart';

import 'moro_exercise_screen.dart';
import 'moro_models.dart';
import 'moro_progress_store.dart';
import 'moro_repository.dart';
import 'moro_speed_store.dart';

class MoroTrainingScreen extends StatefulWidget {
  const MoroTrainingScreen({super.key});
  @override
  State<MoroTrainingScreen> createState() => _MoroTrainingScreenState();
}

class _MoroTrainingScreenState extends State<MoroTrainingScreen> {
  late Future<List<MoroExercise>> _future;
  final Map<int, int> _offsets = {}; // exerciseIndex -> offset (0..3)
  Future<MoroProgressData>? _progressFuture;

  @override
  void initState() {
    super.initState();
    _future = MoroRepository().load();
    _progressFuture = MoroProgressStore.load();
  }

  Future<int> _getOffset(int idx) async {
    if (_offsets.containsKey(idx)) return _offsets[idx]!;
    final v = await MoroSpeedStore.getOffsetForExercise(idx);
    _offsets[idx] = v;
    return v;
  }

  Future<void> _setOffset(int idx, int v) async {
    await MoroSpeedStore.setOffsetForExercise(idx, v);
    setState(() => _offsets[idx] = v);
  }

  Future<void> _refreshProgress(int total) async {
    final data = await MoroProgressStore.load(totalExercises: total);
    if (!mounted) return;
    setState(() {
      _progressFuture = Future.value(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moro Training')),
      body: FutureBuilder<List<MoroExercise>>(
        future: _future,
        builder: (c, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Fehler beim Laden: ${snap.error}'));
          }
          final items = snap.data ?? const <MoroExercise>[];
          if (_progressFuture == null) {
            _progressFuture = MoroProgressStore.load(totalExercises: items.length);
          }
          return FutureBuilder<MoroProgressData>(
            future: _progressFuture,
            builder: (context, progressSnap) {
              if (!progressSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final progress = progressSnap.data!;
              return RefreshIndicator(
                onRefresh: () => _refreshProgress(items.length),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: items.map((ex) {
                    final isUnlocked = ex.index <= progress.highestUnlocked;
                    final isCompleted = progress.completed.contains(ex.index);
                    final lockLabel = isUnlocked
                        ? (isCompleted ? 'Abgeschlossen' : 'Bereit')
                        : 'Gesperrt';
                    final MaterialColor lockColor = isUnlocked
                        ? (isCompleted ? Colors.green : Colors.blue)
                        : Colors.grey;
                    final Color labelColor = isUnlocked
                        ? (isCompleted
                            ? Colors.green.shade700
                            : Colors.blue.shade700)
                        : Colors.grey.shade700;
                    return FutureBuilder<int>(
                      future: _getOffset(ex.index),
                      builder: (context, ofsSnap) {
                        final offs = ofsSnap.data ?? 0;
                        final subtitle = ex.type == MoroExerciseType.phased4x
                            ? '3 Durchgänge · ${ex.phasesPerRepeat} Phasen × ${(ex.baseSeconds + offs)}s · Pause 3s'
                            : '6 Wiederholungen · ${(ex.baseSeconds + offs)}s Aktivität · Pause 3s';

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${ex.index}. ${ex.title}',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(lockLabel),
                                      backgroundColor: lockColor.withAlpha(26),
                                      labelStyle: TextStyle(color: labelColor),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(ex.goal),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: -6,
                                  children: ex.tags
                                      .map(
                                        (tag) => Chip(
                                          label: Text(tag),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      )
                                      .toList(),
                                ),
                                const SizedBox(height: 8),
                                if (ex.notes != null && ex.notes!.isNotEmpty) ...[
                                  Text(
                                    ex.notes!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                Row(
                                  children: [
                                    _SpeedChips(
                                      value: offs,
                                      onChanged: isUnlocked ? (v) => _setOffset(ex.index, v) : null,
                                    ),
                                    const Spacer(),
                                    ElevatedButton.icon(
                                      onPressed: isUnlocked
                                          ? () => _openExercise(context, ex, offs, items.length)
                                          : null,
                                      icon: const Icon(Icons.play_arrow),
                                      label: const Text('Start'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openExercise(
    BuildContext context,
    MoroExercise ex,
    int offset,
    int totalExercises,
  ) async {
    final result = await context.pushNamed(
      AppRouteNames.moroExercise,
      pathParameters: {'exerciseId': '${ex.index}'},
      extra: MoroExerciseScreenArgs(
        exercise: ex,
        offset: offset,
      ),
    );
    if (!context.mounted) return;
    if (result is MoroExerciseResult && result.completed) {
      await MoroProgressStore.markCompleted(ex.index, totalExercises);
      await _refreshProgress(totalExercises);
      final summary = SessionCompletionSummary(
        totalDuration: result.duration ?? const Duration(),
        totalExercises: 1,
        totalRepetitions: ex.repeats,
        phaseLabel: ex.title,
      );
      final action = await showSessionCompletionDialog(
        context,
        summary: summary,
      );
      if (!context.mounted) return;
      switch (action) {
        case SessionCompletionAction.openCalendar:
          context.goNamed(AppRouteNames.calendar);
          break;
        case SessionCompletionAction.giveFeedback:
          context.pushNamed(AppRouteNames.questionnaireIntro);
          break;
        case SessionCompletionAction.planNext:
        case SessionCompletionAction.close:
        case null:
          context.goNamed(AppRouteNames.dashboard);
          break;
      }
    }
  }
}

class _SpeedChips extends StatelessWidget {
  final int value; // 0..3
  final ValueChanged<int>? onChanged;
  const _SpeedChips({required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    const opts = [0, 1, 2, 3];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value == 0 ? 'Standard' : '+${value}s',
          style: const TextStyle(fontSize: 12),
        ),
        Wrap(
          spacing: 6,
          children: opts.map((v) {
            return ChoiceChip(
              label: Text(v == 0 ? 'Std' : '+${v}s'),
              selected: v == value,
              onSelected: onChanged == null ? null : (_) => onChanged!(v),
            );
          }).toList(),
        ),
      ],
    );
  }
}
