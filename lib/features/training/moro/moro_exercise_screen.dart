import 'dart:async';

import 'package:flutter/material.dart';

import 'moro_log_store.dart';
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

class MoroExerciseResult {
  final bool completed;
  final Duration? duration;
  final int? tension;
  final int? pain;
  final String? notes;

  const MoroExerciseResult({
    required this.completed,
    this.duration,
    this.tension,
    this.pain,
    this.notes,
  });
}

enum _MoroStage { preroll, setup, play, cooldown, log }

const _prerollChecklist = [
  'Beine parallel, nicht überkreuzen',
  'Handflächen flach/offen auflegen',
  'Augen offen',
];

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
  final Map<int, bool> _checkStates = {
    for (var i = 0; i < _prerollChecklist.length; i++) i: false,
  };
  _MoroStage _stage = _MoroStage.preroll;
  bool _matReady = false;
  bool _timerSound = true;
  bool _musicOff = true;
  StreamSubscription? _subscription;
  late final CancelToken _cancelToken;
  bool _timerStarted = false;
  int _repeat = 1;
  int _phase = 1;
  Duration _remaining = Duration.zero;
  Duration? _sessionDuration;
  bool _completed = false;
  final TextEditingController _notesController = TextEditingController();
  double _tensionValue = 5;
  double _painValue = 1;

  @override
  void initState() {
    super.initState();
    _cancelToken = CancelToken();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _cancelToken.cancel();
    _notesController.dispose();
    super.dispose();
  }

  Future<bool> _handleWillPop() async {
    _cancelTimer();
    Navigator.of(context).pop(const MoroExerciseResult(completed: false));
    return false;
  }

  void _cancelTimer() {
    _subscription?.cancel();
    _subscription = null;
    _cancelToken.cancel();
  }

  void _startTimerIfNeeded() {
    if (_timerStarted || _completed) return;
    _timerStarted = true;
    final ex = widget.exercise;
    if (ex.type == MoroExerciseType.phased4x) {
      final timer = PhasedMoroTimer(
        repeats: ex.repeats,
        phasesPerRepeat: ex.phasesPerRepeat,
        phaseSeconds: ex.baseSeconds + widget.offset,
      );
      final totalDuration = timer.totalDuration;
      _sessionDuration = totalDuration;
      _subscription = timer.run(_cancelToken).listen((event) {
        if (!mounted) return;
        setState(() {
          _repeat = event.repeatIdx;
          _phase = event.phaseIdx;
          _remaining = event.remaining;
        });
        if (event.done && mounted) {
          _onTimerCompleted(totalDuration);
        }
      });
    } else {
      final timer = SimpleMoroTimer(
        repeats: ex.repeats,
        repeatSeconds: ex.baseSeconds + widget.offset,
      );
      final totalDuration = timer.totalDuration;
      _sessionDuration = totalDuration;
      _subscription = timer.run(_cancelToken).listen((event) {
        if (!mounted) return;
        setState(() {
          _repeat = event.repeatIdx;
          _phase = 1;
          _remaining = event.remaining;
        });
        if (event.done && mounted) {
          _onTimerCompleted(totalDuration);
        }
      });
    }
  }

  void _onTimerCompleted(Duration total) {
    _cancelTimer();
    setState(() {
      _completed = true;
      _stage = _MoroStage.cooldown;
      _sessionDuration = total;
    });
  }

  double _segmentProgress() {
    final totalSeconds = widget.exercise.baseSeconds + widget.offset;
    if (totalSeconds <= 0) {
      return 0;
    }
    final remainingMs = _remaining.inMilliseconds.clamp(0, totalSeconds * 1000);
    return 1 - remainingMs / (totalSeconds * 1000);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return minutes > 0 ? '$minutes:$seconds min' : '$seconds s';
  }

  Widget _buildStageContent() {
    switch (_stage) {
      case _MoroStage.preroll:
        return _buildPreroll();
      case _MoroStage.setup:
        return _buildSetup();
      case _MoroStage.play:
        _startTimerIfNeeded();
        return _buildPlayer();
      case _MoroStage.cooldown:
        return _buildCooldown();
      case _MoroStage.log:
        return _buildLog();
    }
  }

  Widget _buildPreroll() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preroll Check', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ..._prerollChecklist.asMap().entries.map((entry) {
          final idx = entry.key;
          final label = entry.value;
          return CheckboxListTile(
            value: _checkStates[idx],
            onChanged: (v) => setState(() => _checkStates[idx] = v ?? false),
            title: Text(label),
          );
        }),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _checkStates.values.every((v) => v)
                ? () => setState(() => _stage = _MoroStage.setup)
                : null,
            child: const Text('Weiter zu Setup'),
          ),
        ),
      ],
    );
  }

  Widget _buildSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Setup', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SwitchListTile(
          value: _matReady,
          onChanged: (v) => setState(() => _matReady = v),
          title: const Text('Matte bereitgelegt'),
        ),
        SwitchListTile(
          value: _timerSound,
          onChanged: (v) => setState(() => _timerSound = v),
          title: const Text('Timer-Sound aktiv'),
        ),
        SwitchListTile(
          value: _musicOff,
          onChanged: (v) => setState(() => _musicOff = v),
          title: const Text('Musik aus / Fokusmodus'),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _matReady && _timerSound && _musicOff
                ? () => setState(() => _stage = _MoroStage.play)
                : null,
            child: const Text('Session starten'),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayer() {
    final ex = widget.exercise;
    final phaseInfo = ex.type == MoroExerciseType.phased4x
        ? 'Phase: $_phase / ${ex.phasesPerRepeat}'
        : 'Aktive Wiederholung';
    final totalRepeats = ex.repeats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Übung ${ex.index}', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(ex.goal),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: _segmentProgress().clamp(0.0, 1.0)),
        const SizedBox(height: 8),
        Text('Wiederholung: $_repeat / $totalRepeats'),
        Text(phaseInfo),
        const SizedBox(height: 12),
        Text('Restzeit aktuelle Phase: ${_remaining.inSeconds}s'),
        const SizedBox(height: 16),
        Text('Schritte', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDefinitionTile('Startposition', ex.startPosition),
                if (ex.endPosition != null && ex.endPosition!.isNotEmpty)
                  _buildDefinitionTile('Endposition', ex.endPosition!),
                _buildDefinitionTile(
                  'Atmung',
                  _describeBreath(ex.breath),
                ),
                const SizedBox(height: 12),
                ...ex.steps.map((step) => ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 14,
                        child: Text('${step.order}'),
                      ),
                      title: Text(step.text),
                      subtitle: step.durationSec != null
                          ? Text('${step.durationSec}s')
                          : null,
                    )),
                const SizedBox(height: 12),
                Text('Cues', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...ex.cues.map((cue) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(cue),
                    )),
                const SizedBox(height: 12),
                Text('Abort-Kriterien', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...ex.abortRules.map((rule) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.warning_amber_outlined),
                      title: Text(rule),
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              _cancelTimer();
              Navigator.of(context)
                  .maybePop(const MoroExerciseResult(completed: false));
            },
            child: const Text('Abbrechen'),
          ),
        ),
      ],
    );
  }

  Widget _buildCooldown() {
    final duration = _sessionDuration ?? const Duration();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cooldown', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.timer_outlined),
          title: const Text('Gesamtdauer'),
          subtitle: Text(_formatDuration(duration)),
        ),
        ListTile(
          leading: const Icon(Icons.check_circle_outline),
          title: const Text('Status'),
          subtitle: Text(_completed ? 'Abgeschlossen' : 'Nicht abgeschlossen'),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _completed
                ? () => setState(() => _stage = _MoroStage.log)
                : () => Navigator.of(context)
                    .maybePop(const MoroExerciseResult(completed: false)),
            child: Text(_completed ? 'Zum Protokoll' : 'Zurück zur Übersicht'),
          ),
        ),
      ],
    );
  }

  Widget _buildLog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Session-Log', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        _buildSlider(
          label: 'Spannung',
          value: _tensionValue,
          onChanged: (v) => setState(() => _tensionValue = v),
        ),
        _buildSlider(
          label: 'Schmerz',
          value: _painValue,
          onChanged: (v) => setState(() => _painValue = v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Notizen',
            border: OutlineInputBorder(),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveLogAndClose,
            child: const Text('Speichern & schließen'),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).maybePop(MoroExerciseResult(
              completed: true,
              duration: _sessionDuration,
            ));
          },
          child: const Text('Ohne Log schließen'),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        Slider(
          value: value,
          min: 1,
          max: 10,
          divisions: 9,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDefinitionTile(String title, String body) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(body),
        ],
      ),
    );
  }

  String _describeBreath(MoroBreathPattern pattern) {
    final buffer = StringBuffer();
    buffer.write(pattern.pattern);
    if (pattern.exhaleSec != null) {
      buffer.write(' · Ausatmung ca. ${pattern.exhaleSec}s');
    }
    if (pattern.holdSec != null) {
      buffer.write(' · Halten ${pattern.holdSec}s');
    }
    if (pattern.notes != null && pattern.notes!.isNotEmpty) {
      buffer.write(' — ${pattern.notes}');
    }
    return buffer.toString();
  }

  Future<void> _saveLogAndClose() async {
    final entry = MoroLogEntry(
      timestamp: DateTime.now(),
      exerciseIndex: widget.exercise.index,
      tension: _tensionValue.round(),
      pain: _painValue.round(),
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );
    await MoroLogStore.addEntry(entry);
    if (!mounted) return;
    Navigator.of(context).maybePop(MoroExerciseResult(
      completed: true,
      duration: _sessionDuration,
      tension: entry.tension,
      pain: entry.pain,
      notes: entry.notes,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(ex.title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _cancelTimer();
              Navigator.of(context)
                  .maybePop(const MoroExerciseResult(completed: false));
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildStageContent(),
        ),
      ),
    );
  }
}
