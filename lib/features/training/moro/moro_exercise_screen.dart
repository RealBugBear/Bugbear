import 'dart:async';

import 'package:flutter/material.dart';

import 'moro_models.dart';
import 'timers.dart';

class MoroExerciseScreenArgs {
  final MoroExercise exercise;
  final int offset;

  const MoroExerciseScreenArgs({
    required this.exercise,
    required this.offset,
  });
}

class MoroExerciseScreen extends StatefulWidget {
  final MoroExercise exercise;
  final int offset;

  const MoroExerciseScreen({
    super.key,
    required this.exercise,
    required this.offset,
  });

  @override
  State<MoroExerciseScreen> createState() => _MoroExerciseScreenState();
}

class _MoroExerciseScreenState extends State<MoroExerciseScreen> {
  late final CancelToken _cancelToken;
  StreamSubscription? _subscription;
  int _repeat = 1;
  int _phase = 1;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _cancelToken = CancelToken();
    _startTimer();
  }

  void _startTimer() {
    final ex = widget.exercise;
    if (ex.type == MoroExerciseType.phased4x) {
      final timer = PhasedMoroTimer(
        repeats: ex.repeats,
        phasesPerRepeat: ex.phasesPerRepeat,
        phaseSeconds: ex.baseSeconds + widget.offset,
      );
      _subscription = timer.run(_cancelToken).listen((event) {
        if (!mounted) return;
        setState(() {
          _repeat = event.repeatIdx;
          _phase = event.phaseIdx;
          _remaining = event.remaining;
        });
        if (event.done && mounted) {
          Navigator.of(context).maybePop();
        }
      });
    } else {
      final timer = SimpleMoroTimer(
        repeats: ex.repeats,
        repeatSeconds: ex.baseSeconds + widget.offset,
      );
      _subscription = timer.run(_cancelToken).listen((event) {
        if (!mounted) return;
        setState(() {
          _repeat = event.repeatIdx;
          _phase = 1;
          _remaining = event.remaining;
        });
        if (event.done && mounted) {
          Navigator.of(context).maybePop();
        }
      });
    }
  }

  double _segmentProgress() {
    final totalSeconds = widget.exercise.baseSeconds + widget.offset;
    if (totalSeconds <= 0) {
      return 0;
    }
    final remainingMs = _remaining.inMilliseconds.clamp(0, totalSeconds * 1000);
    return 1 - remainingMs / (totalSeconds * 1000);
  }

  Future<bool> _handleWillPop() async {
    _cancelToken.cancel();
    return true;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _cancelToken.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final phaseInfo = ex.type == MoroExerciseType.phased4x
        ? 'Phase: $_phase / ${ex.phasesPerRepeat}'
        : 'Aktive Wiederholung';

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(ex.title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _cancelToken.cancel();
              Navigator.of(context).maybePop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Übung ${ex.index}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Text('Wiederholung: $_repeat / ${ex.repeats}'),
              const SizedBox(height: 4),
              Text(phaseInfo),
              const SizedBox(height: 24),
              LinearProgressIndicator(value: _segmentProgress().clamp(0.0, 1.0)),
              const SizedBox(height: 12),
              Text('Restzeit: ${_remaining.inSeconds}s'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _cancelToken.cancel();
                    Navigator.of(context).maybePop();
                  },
                  child: const Text('Abbrechen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
