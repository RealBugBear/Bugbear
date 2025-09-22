import 'dart:async';

import 'package:flutter/material.dart';

import 'moro_models.dart';
import 'moro_repository.dart';
import 'moro_speed_store.dart';
import 'timers.dart';

class MoroTrainingScreen extends StatefulWidget {
  const MoroTrainingScreen({super.key});

  @override
  State<MoroTrainingScreen> createState() => _MoroTrainingScreenState();
}

class _MoroTrainingScreenState extends State<MoroTrainingScreen> {
  late Future<List<MoroExercise>> _future;
  final Map<int, int> _offsets = <int, int>{};

  @override
  void initState() {
    super.initState();
    _future = MoroRepository().load();
  }

  Future<int> _getOffset(int index) async {
    if (_offsets.containsKey(index)) {
      return _offsets[index]!;
    }
    final value = await MoroSpeedStore.getOffsetForExercise(index);
    _offsets[index] = value;
    return value;
  }

  Future<void> _setOffset(int index, int value) async {
    await MoroSpeedStore.setOffsetForExercise(index, value);
    setState(() {
      _offsets[index] = value;
    });
  }

  void _openExercise(BuildContext context, MoroExercise exercise, int offset) {
    final token = CancelToken();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MoroRunDialog(
        exercise: exercise,
        offset: offset,
        cancelToken: token,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moro Training'),
      ),
      body: FutureBuilder<List<MoroExercise>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final exercises = snapshot.data ?? <MoroExercise>[];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return FutureBuilder<int>(
                future: _getOffset(exercise.index),
                builder: (context, offsetSnapshot) {
                  final offset = offsetSnapshot.data ?? _offsets[exercise.index] ?? 0;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SpeedChips(
                            value: offset,
                            onChanged: (value) => _setOffset(exercise.index, value),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${exercise.index}. ${exercise.title}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  exercise.type == MoroExerciseType.phased4x
                                      ? '3 Wiederholungen · 4 Phasen × ${exercise.baseSeconds + offset}s · Pause 3s'
                                      : '6 Wiederholungen · ${exercise.baseSeconds + offset}s pro Wiederholung · Pause 3s',
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: ElevatedButton(
                                    onPressed: () => _openExercise(context, exercise, offset),
                                    child: const Text('Start'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: exercises.length,
          );
        },
      ),
    );
  }
}

class _SpeedChips extends StatelessWidget {
  const _SpeedChips({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = List<int>.generate(4, (index) => index);
    return SizedBox(
      width: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value == 0 ? 'Standard' : '+${value}s',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final option in options)
                ChoiceChip(
                  label: Text(option == 0 ? 'Std' : '+${option}s'),
                  selected: option == value,
                  onSelected: (_) => onChanged(option),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoroRunDialog extends StatefulWidget {
  const _MoroRunDialog({
    required this.exercise,
    required this.offset,
    required this.cancelToken,
  });

  final MoroExercise exercise;
  final int offset;
  final CancelToken cancelToken;

  @override
  State<_MoroRunDialog> createState() => _MoroRunDialogState();
}

class _MoroRunDialogState extends State<_MoroRunDialog> {
  StreamSubscription<dynamic>? _subscription;
  int _repeat = 1;
  int _phase = 1;
  Duration _remaining = Duration.zero;
  double _progress = 0;

  int get _unitSeconds => widget.exercise.baseSeconds + widget.offset;

  @override
  void initState() {
    super.initState();
    if (widget.exercise.type == MoroExerciseType.phased4x) {
      final timer = PhasedMoroTimer(
        repeats: widget.exercise.repeats,
        phasesPerRepeat: widget.exercise.phasesPerRepeat,
        phaseSeconds: _unitSeconds,
      );
      _subscription = timer.run(widget.cancelToken).listen((event) {
        if (!mounted) {
          return;
        }
        setState(() {
          _repeat = event.repeatIdx;
          _phase = event.phaseIdx;
          _remaining = event.remaining;
          _progress = _calculatePhasedProgress(event.repeatIdx, event.phaseIdx, event.remaining);
        });
        if (event.done && mounted) {
          Navigator.of(context).pop();
        }
      });
    } else {
      final timer = SimpleMoroTimer(
        repeats: widget.exercise.repeats,
        repeatSeconds: _unitSeconds,
      );
      _subscription = timer.run(widget.cancelToken).listen((event) {
        if (!mounted) {
          return;
        }
        setState(() {
          _repeat = event.repeatIdx;
          _phase = 1;
          _remaining = event.remaining;
          _progress = _calculateSimpleProgress(event.repeatIdx, event.remaining);
        });
        if (event.done && mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  double _calculatePhasedProgress(int repeat, int phase, Duration remaining) {
    final totalPhases = widget.exercise.repeats * widget.exercise.phasesPerRepeat;
    final completedPhases = (repeat - 1) * widget.exercise.phasesPerRepeat + (phase - 1);
    final phaseMillis = _unitSeconds * 1000;
    final remainingMillis = remaining.inMilliseconds.clamp(0, phaseMillis);
    final currentProgress = phaseMillis == 0
        ? 1.0
        : 1 - (remainingMillis / phaseMillis);
    final overall = (completedPhases + currentProgress) / totalPhases;
    return overall.clamp(0, 1);
  }

  double _calculateSimpleProgress(int repeat, Duration remaining) {
    final totalRepeats = widget.exercise.repeats;
    final completedRepeats = repeat - 1;
    final unitMillis = _unitSeconds * 1000;
    final remainingMillis = remaining.inMilliseconds.clamp(0, unitMillis);
    final currentProgress = unitMillis == 0
        ? 1.0
        : 1 - (remainingMillis / unitMillis);
    final overall = (completedRepeats + currentProgress) / totalRepeats;
    return overall.clamp(0, 1);
  }

  int _remainingSecondsCeil() {
    final ms = _remaining.inMilliseconds;
    if (ms <= 0) {
      return 0;
    }
    return (ms / 1000).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    return AlertDialog(
      title: Text(exercise.title),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wiederholung: $_repeat / ${exercise.repeats}'),
            if (exercise.type == MoroExerciseType.phased4x)
              Text('Phase: $_phase / ${exercise.phasesPerRepeat}'),
            const SizedBox(height: 12),
            Text('Restzeit: ${_remainingSecondsCeil()}s'),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: _progress),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.cancelToken.cancel();
            Navigator.of(context).pop();
          },
          child: const Text('Abbrechen'),
        ),
      ],
    );
  }
}
