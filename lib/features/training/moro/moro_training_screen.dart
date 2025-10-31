import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/services/app_routes.dart';

import 'moro_exercise_screen.dart';
import 'moro_models.dart';
import 'moro_progress_store.dart';
import 'moro_repository.dart';
import 'moro_speed_store.dart';
import 'pre_check_screen.dart';

class MoroTrainingScreen extends StatefulWidget {
  const MoroTrainingScreen({super.key});
  @override
  State<MoroTrainingScreen> createState() => _MoroTrainingScreenState();
}

class _MoroTrainingScreenState extends State<MoroTrainingScreen> {
  late Future<List<MoroExercise>> _future;
  final Map<int, int> _offsets = {}; // exerciseIndex -> offset (0..3)
  Future<MoroProgressData>? _progressFuture;
  bool _autoplayEnabled = true;
  int _autoplayDelaySeconds = 3;
  bool _autoplayInitialized = false;

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

  Widget _buildStartCard(
    BuildContext context,
    List<MoroExercise> items,
    MoroProgressData progress,
    SessionNotifier notifier,
  ) {
    final startExercise = _determineStartExercise(items, progress, notifier);
    final hasResume = notifier.state.moroResume.isNotEmpty;
    final subtitle = hasResume
        ? 'Fortsetzen bei Übung ${startExercise.index}'
        : 'Nächste Übung: ${startExercise.index}. ${startExercise.title}';
    final autoplayLabel = _autoplayEnabled
        ? 'Autoplay ${_autoplayDelaySeconds}s'
        : 'Autoplay aus';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Moro-Session'),
              subtitle: Text(subtitle),
              trailing: Chip(label: Text(autoplayLabel)),
            ),
            if (hasResume)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'Zwischenspeicher gefunden – du kannst jederzeit neu starten.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: Text(hasResume ? 'Fortsetzen' : 'Training starten'),
                onPressed: () => _startFromPrecheck(
                  context,
                  items,
                  progress,
                  notifier,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  MoroExercise _determineStartExercise(
    List<MoroExercise> items,
    MoroProgressData progress,
    SessionNotifier notifier,
  ) {
    final resume = notifier.state.moroResume;
    for (final ex in items) {
      if (resume.containsKey(ex.resumeKey)) {
        return ex;
      }
    }
    for (final ex in items) {
      if (!progress.completed.contains(ex.index)) {
        return ex;
      }
    }
    if (items.isNotEmpty) {
      return items.first;
    }
    throw StateError('Es wurden keine Moro-Übungen konfiguriert.');
  }

  Future<void> _startFromPrecheck(
    BuildContext context,
    List<MoroExercise> items,
    MoroProgressData progress,
    SessionNotifier notifier,
  ) async {
    final result = await context.pushNamed(AppRouteNames.moroPrecheck);
    if (result is! MoroPreCheckResult) {
      return;
    }
    setState(() {
      _autoplayEnabled = result.autoplayEnabled;
      _autoplayDelaySeconds = result.autoplayDelaySeconds;
      _autoplayInitialized = true;
    });
    notifier.startMoroSession();
    final startExercise = _determineStartExercise(items, progress, notifier);
    final offset = await _getOffset(startExercise.index);
    if (!mounted) return;
    await _openExercise(context, startExercise, offset, items.length, items);
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
          if (!_autoplayInitialized && items.isNotEmpty) {
            _autoplayDelaySeconds = items.first.autoplayDefault;
            _autoplayInitialized = true;
          }
          return FutureBuilder<MoroProgressData>(
            future: _progressFuture,
            builder: (context, progressSnap) {
              if (!progressSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final progress = progressSnap.data!;
              final sessionNotifier = context.watch<SessionNotifier>();
              final header = _buildStartCard(
                context,
                items,
                progress,
                sessionNotifier,
              );
              final tiles = items.map((ex) {
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
                                          ? () => _openExercise(
                                                context,
                                                ex,
                                                offs,
                                                items.length,
                                                items,
                                              )
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
                  }).toList();
              return RefreshIndicator(
                onRefresh: () => _refreshProgress(items.length),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    header,
                    const SizedBox(height: 12),
                    ...tiles,
                  ],
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
    List<MoroExercise> allExercises,
  ) async {
    context.read<SessionNotifier>().startMoroSession();
    final result = await context.pushNamed(
      AppRouteNames.moroExercise,
      pathParameters: {'exerciseId': '${ex.index}'},
      extra: MoroExerciseScreenArgs(
        exercise: ex,
        offset: offset,
        autoplay: _autoplayEnabled,
        autoplayDelaySeconds: _autoplayDelaySeconds,
        totalExercises: totalExercises,
      ),
    );
    if (!context.mounted) return;
    if (result is MoroExerciseResult) {
      if (result.completed) {
        context.read<SessionNotifier>().applyXpReward(xp: ex.xpReward);
        await MoroProgressStore.markCompleted(ex.index, totalExercises);
        await _refreshProgress(totalExercises);
        if (result.hasNextExercise && result.autoplayEnabled) {
          final nextIndex = ex.index + 1;
          final nextExercise = allExercises.firstWhere(
            (element) => element.index == nextIndex,
            orElse: () => allExercises.last,
          );
          final nextOffset = await _getOffset(nextExercise.index);
          if (!context.mounted) return;
          await _openExercise(
            context,
            nextExercise,
            nextOffset,
            totalExercises,
            allExercises,
          );
          return;
        }
        if (!result.hasNextExercise) {
          if (!context.mounted) return;
          context.goNamed(AppRouteNames.trainingCompleted);
        }
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
