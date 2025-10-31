import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../notifier/session_notifier.dart';
import 'media_player_service.dart';
import 'moro_log_store.dart';
import 'moro_models.dart';
import 'moro_session_controller.dart';

class MoroExerciseScreenArgs {
  final MoroExercise exercise;
  final int offset;
  final bool autoplay;
  final int autoplayDelaySeconds;
  final int totalExercises;

  const MoroExerciseScreenArgs({
    required this.exercise,
    required this.offset,
    required this.autoplay,
    required this.autoplayDelaySeconds,
    required this.totalExercises,
  });
}

class MoroExerciseResult {
  final bool completed;
  final Duration? duration;
  final bool autoplayEnabled;
  final int autoplayDelaySeconds;
  final int exerciseIndex;
  final bool hasNextExercise;
  final int? tension;
  final int? pain;
  final String? notes;

  const MoroExerciseResult({
    required this.completed,
    required this.autoplayEnabled,
    required this.autoplayDelaySeconds,
    required this.exerciseIndex,
    required this.hasNextExercise,
    this.duration,
    this.tension,
    this.pain,
    this.notes,
  });
}

const _preCheckItems = [
  'Beine parallel, nicht überkreuzen',
  'Handflächen flach/offen auflegen',
  'Augen offen',
];

class MoroExerciseScreen extends StatefulWidget {
  final MoroExercise exercise;
  final int offset;
  final bool autoplay;
  final int autoplayDelaySeconds;
  final int totalExercises;

  const MoroExerciseScreen({
    super.key,
    required this.exercise,
    required this.offset,
    required this.autoplay,
    required this.autoplayDelaySeconds,
    required this.totalExercises,
  });

  @override
  State<MoroExerciseScreen> createState() => _MoroExerciseScreenState();
}

class _MoroExerciseScreenState extends State<MoroExerciseScreen> {
  late final TextEditingController _notesController;
  late final MoroMediaPlayerService _mediaService;
  MoroMediaLoadResult? _mediaResult;
  bool _mediaLoading = true;
  bool _mediaErrorAcknowledged = false;

  late final Map<int, bool> _checkStates;
  bool _matReady = false;
  bool _timerSound = true;
  bool _musicOff = true;
  double _tensionValue = 5;
  double _painValue = 1;

  MoroSessionController? _controller;
  MoroSessionSnapshot? _pendingSnapshot;
  bool _resumePromptShown = false;
  bool _didComplete = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _mediaService = MoroMediaPlayerService();
    _checkStates = {
      for (var i = 0; i < _preCheckItems.length; i++) i: false,
    };
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    final result = await _mediaService.loadForExercise(widget.exercise);
    if (!mounted) return;
    setState(() {
      _mediaResult = result;
      _mediaLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = context.read<SessionNotifier>();
    if (_controller == null) {
      final resumeJson = notifier.getResumePoint(widget.exercise.resumeKey);
      _pendingSnapshot = MoroSessionSnapshot.fromJson(resumeJson);
      _controller = MoroSessionController(
        exercise: widget.exercise,
        offset: widget.offset,
        autoplay: widget.autoplay,
        autoplayDelaySeconds: widget.autoplayDelaySeconds,
        onResumeChanged: (payload) {
          if (payload == null) {
            notifier.clearResumePoint(widget.exercise.resumeKey);
          } else {
            notifier.saveResumePoint(widget.exercise.resumeKey, payload);
          }
        },
      );
      _controller!.addListener(_onControllerChanged);
      if (_pendingSnapshot == null) {
        _controller!.startIntro();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _resumePromptShown) return;
          _resumePromptShown = true;
          _showResumeDialog();
        });
      }
    }
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showResumeDialog() async {
    if (_pendingSnapshot == null) {
      _controller?.startIntro();
      return;
    }
    final shouldResume = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Fortsetzen?'),
            content: const Text(
              'Wir haben einen Zwischenspeicher gefunden. Möchtest du an der letzten Stelle fortfahren?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Neu starten'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Fortsetzen'),
              ),
            ],
          ),
        ) ??
        false;
    final notifier = context.read<SessionNotifier>();
    if (shouldResume) {
      _controller?.restoreFrom(_pendingSnapshot!);
      _pendingSnapshot = null;
    } else {
      notifier.clearResumePoint(widget.exercise.resumeKey);
      _controller?.startIntro();
      _pendingSnapshot = null;
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    _controller?.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleAbort() {
    _controller?.abort();
    Navigator.of(context).maybePop(
      MoroExerciseResult(
        completed: false,
        autoplayEnabled: widget.autoplay,
        autoplayDelaySeconds: widget.autoplayDelaySeconds,
        exerciseIndex: widget.exercise.index,
        hasNextExercise: widget.exercise.index < widget.totalExercises,
      ),
    );
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
    context.read<SessionNotifier>().clearResumePoint(widget.exercise.resumeKey);
    Navigator.of(context).maybePop(
      MoroExerciseResult(
        completed: true,
        autoplayEnabled: widget.autoplay,
        autoplayDelaySeconds: widget.autoplayDelaySeconds,
        exerciseIndex: widget.exercise.index,
        hasNextExercise: widget.exercise.index < widget.totalExercises,
        duration: _controller?.sessionDuration,
        tension: entry.tension,
        pain: entry.pain,
        notes: entry.notes,
      ),
    );
  }

  Widget _buildStageContent(MoroSessionController controller) {
    switch (controller.stage) {
      case MoroSessionStage.intro:
        return _buildIntro(controller);
      case MoroSessionStage.delay:
        return _buildDelay(controller);
      case MoroSessionStage.active:
        return _buildActive(controller);
      case MoroSessionStage.pause:
        return _buildPause(controller);
      case MoroSessionStage.cooldown:
        return _buildCooldown(controller);
      case MoroSessionStage.log:
        return _buildLog();
    }
  }

  Widget _buildIntro(MoroSessionController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vorbereitung', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ..._preCheckItems.asMap().entries.map(
          (entry) => CheckboxListTile(
            value: _checkStates[entry.key],
            onChanged: (v) => setState(() => _checkStates[entry.key] = v ?? false),
            title: Text(entry.value),
          ),
        ),
        const Divider(height: 32),
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
            onPressed: _checkStates.values.every((v) => v) && _matReady && _timerSound && _musicOff
                ? () {
                    setState(() {
                      _didComplete = false;
                    });
                    controller.beginDelay();
                  }
                : null,
            child: const Text('Übung starten'),
          ),
        ),
      ],
    );
  }

  Widget _buildDelay(MoroSessionController controller) {
    final remaining = controller.pauseRemaining.inMilliseconds;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Bereit machen...'),
        const SizedBox(height: 16),
        CircularProgressIndicator(
          value: remaining <= 0
              ? 1
              : 1 - remaining / const Duration(seconds: 3).inMilliseconds,
        ),
        const SizedBox(height: 16),
        Text('${(remaining / 1000).ceil()} s'),
      ],
    );
  }

  Widget _buildActive(MoroSessionController controller) {
    final ex = widget.exercise;
    final phaseInfo = ex.type == MoroExerciseType.phased4x
        ? 'Phase: ${controller.phaseIdx} / ${ex.phasesPerRepeat}'
        : 'Aktive Spannung';
    final totalRepeats = ex.repeats;
    final remainingSeconds = controller.remaining.inSeconds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Übung ${ex.index}', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_mediaLoading)
          const LinearProgressIndicator()
        else if (_mediaResult?.hasVideo == true)
          _buildMediaBanner(Icons.play_circle_outline, 'Video verfügbar')
        else if (_mediaResult?.hasImage == true)
          _buildImagePreview(_mediaResult!.imageAsset!)
        else
          _buildMediaBanner(Icons.image_not_supported_outlined, 'Visuelle Anleitung nicht verfügbar'),
        if ((_mediaResult?.hasError ?? false) && !_mediaErrorAcknowledged)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.info_outline),
              label: const Text('Fallback anzeigen'),
              onPressed: () => setState(() => _mediaErrorAcknowledged = true),
            ),
          ),
        const SizedBox(height: 12),
        Text(ex.goal),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: _segmentProgress(ex),
        ),
        const SizedBox(height: 8),
        Text('Wiederholung: ${controller.repeatIdx} / $totalRepeats'),
        Text(phaseInfo),
        const SizedBox(height: 12),
        Text('Restzeit aktuelle Phase: ${remainingSeconds.clamp(0, 999)}s'),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDefinitionTile('Startposition', ex.startPosition),
                if (ex.endPosition != null && ex.endPosition!.isNotEmpty)
                  _buildDefinitionTile('Endposition', ex.endPosition!),
                _buildDefinitionTile('Atmung', _describeBreath(ex.breath)),
                const SizedBox(height: 12),
                ...ex.steps.map((step) => ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 14,
                        child: Text('${step.order}'),
                      ),
                      title: Text(step.text),
                      subtitle:
                          step.durationSec != null ? Text('${step.durationSec}s') : null,
                    )),
                const SizedBox(height: 12),
                Text('Cues', style: Theme.of(context).textTheme.titleMedium),
                ...ex.cues.map((cue) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(cue),
                    )),
                const SizedBox(height: 12),
                Text('Abort-Kriterien', style: Theme.of(context).textTheme.titleMedium),
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
            onPressed: _handleAbort,
            child: const Text('Abbrechen'),
          ),
        ),
      ],
    );
  }

  Widget _buildPause(MoroSessionController controller) {
    final remaining = controller.pauseRemaining.inSeconds;
    final hasAutoplay = widget.autoplay;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pause', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Text(
          hasAutoplay
              ? 'Nächste Übung startet automatisch in $remaining s.'
              : 'Bereit für die nächste Übung? Du kannst den Countdown manuell starten.',
        ),
        if (!hasAutoplay)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.continueAfterPause(),
                child: const Text('Weiter'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCooldown(MoroSessionController controller) {
    final duration = controller.sessionDuration;
    if (!_didComplete) {
      _didComplete = true;
      context.read<SessionNotifier>().clearResumePoint(widget.exercise.resumeKey);
    }
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
          subtitle: const Text('Abgeschlossen'),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _controller?.markLogged(),
            child: const Text('Zum Protokoll'),
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
            context.read<SessionNotifier>().clearResumePoint(widget.exercise.resumeKey);
            Navigator.of(context).maybePop(
              MoroExerciseResult(
                completed: true,
                autoplayEnabled: widget.autoplay,
                autoplayDelaySeconds: widget.autoplayDelaySeconds,
                exerciseIndex: widget.exercise.index,
                hasNextExercise: widget.exercise.index < widget.totalExercises,
                duration: _controller?.sessionDuration,
              ),
            );
          },
          child: const Text('Ohne Log schließen'),
        ),
      ],
    );
  }

  double _segmentProgress(MoroExercise ex) {
    final totalSeconds = ex.baseSeconds + widget.offset;
    if (totalSeconds <= 0) return 0;
    final remainingMs = _controller?.remaining.inMilliseconds ?? 0;
    return 1 - remainingMs / (totalSeconds * 1000);
  }

  Widget _buildMediaBanner(IconData icon, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String asset) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        asset,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return minutes > 0 ? '$minutes:$seconds min' : '$seconds s';
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final ex = widget.exercise;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        _handleAbort();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(ex.title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _handleAbort,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: controller == null
              ? const Center(child: CircularProgressIndicator())
              : _buildStageContent(controller),
        ),
      ),
    );
  }
}
