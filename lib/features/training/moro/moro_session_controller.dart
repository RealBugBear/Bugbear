import 'dart:async';

import 'package:flutter/foundation.dart';

import 'moro_models.dart';
import 'timers.dart';

enum MoroSessionStage { intro, delay, active, pause, cooldown, log }

class MoroSessionSnapshot {
  final MoroSessionStage stage;
  final int repeatIdx;
  final int phaseIdx;
  final int remainingMilliseconds;

  const MoroSessionSnapshot({
    required this.stage,
    required this.repeatIdx,
    required this.phaseIdx,
    required this.remainingMilliseconds,
  });

  Map<String, dynamic> toJson() => {
        'stage': stage.name,
        'repeatIdx': repeatIdx,
        'phaseIdx': phaseIdx,
        'remainingMs': remainingMilliseconds,
      };

  static MoroSessionSnapshot? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final stageName = json['stage'] as String?;
    final stage = MoroSessionStage.values.firstWhere(
      (element) => element.name == stageName,
      orElse: () => MoroSessionStage.intro,
    );
    return MoroSessionSnapshot(
      stage: stage,
      repeatIdx: json['repeatIdx'] as int? ?? 1,
      phaseIdx: json['phaseIdx'] as int? ?? 1,
      remainingMilliseconds: json['remainingMs'] as int? ?? 0,
    );
  }
}

class MoroSessionController extends ChangeNotifier {
  MoroSessionStage _stage = MoroSessionStage.intro;
  final MoroExercise exercise;
  final int offset;
  final bool autoplay;
  final int autoplayDelaySeconds;
  final void Function(Map<String, dynamic>? snapshot)? onResumeChanged;
  CancelToken? _activeToken;
  StreamSubscription? _timerSubscription;
  Timer? _delayTimer;
  Timer? _pauseTimer;

  int _repeatIdx = 1;
  int _phaseIdx = 1;
  Duration _remaining = Duration.zero;
  Duration _pauseRemaining = Duration.zero;
  Duration _sessionDuration = Duration.zero;
  bool _completed = false;

  MoroSessionController({
    required this.exercise,
    required this.offset,
    required this.autoplay,
    required this.autoplayDelaySeconds,
    this.onResumeChanged,
  });

  MoroSessionStage get stage => _stage;
  int get repeatIdx => _repeatIdx;
  int get phaseIdx => _phaseIdx;
  Duration get remaining => _remaining;
  Duration get pauseRemaining => _pauseRemaining;
  Duration get sessionDuration => _sessionDuration;
  bool get isCompleted => _completed;

  void startIntro() {
    _setStage(MoroSessionStage.intro);
  }

  void beginDelay({Duration? duration}) {
    _cancelTimers();
    final delay = duration ?? const Duration(seconds: 3);
    _pauseRemaining = delay;
    _setStage(MoroSessionStage.delay);
    _delayTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      final ms = _pauseRemaining.inMilliseconds - 250;
      if (ms <= 0) {
        timer.cancel();
        _pauseRemaining = Duration.zero;
        _notifyResume();
        startActive();
      } else {
        _pauseRemaining = Duration(milliseconds: ms);
        _notifyResume();
        notifyListeners();
      }
    });
    _notifyResume();
  }

  void startActive() {
    _cancelTimers();
    _setStage(MoroSessionStage.active);
    _repeatIdx = (_repeatIdx <= 0) ? 1 : _repeatIdx;
    _phaseIdx = (_phaseIdx <= 0) ? 1 : _phaseIdx;

    final token = CancelToken();
    _activeToken = token;
    final startRepeat = _repeatIdx.clamp(1, exercise.repeats);
    final startPhase = _phaseIdx.clamp(1, exercise.phasesPerRepeat);
    final initialMs = _remaining.inMilliseconds > 0 ? _remaining.inMilliseconds : null;
    final timer = exercise.type == MoroExerciseType.phased4x
        ? PhasedMoroTimer(
            repeats: exercise.repeats,
            phasesPerRepeat: exercise.phasesPerRepeat,
            phaseSeconds: exercise.baseSeconds + offset,
          ).run(
            token,
            startRepeat: startRepeat,
            startPhase: startPhase,
            initialRemainingMilliseconds: initialMs,
          )
        : SimpleMoroTimer(
            repeats: exercise.repeats,
            repeatSeconds: exercise.baseSeconds + offset,
          ).run(
            token,
            startRepeat: startRepeat,
            initialRemainingMilliseconds: initialMs,
          );
    final sw = Stopwatch()..start();
    _timerSubscription = timer.listen((event) {
      if (!event.done) {
        _repeatIdx = event.repeatIdx;
        _phaseIdx = exercise.type == MoroExerciseType.phased4x
            ? event.phaseIdx
            : 1;
        _remaining = event.remaining;
        _sessionDuration = sw.elapsed;
        _notifyResume();
      } else {
        _sessionDuration = sw.elapsed;
        _remaining = Duration.zero;
        _notifyResume();
        _handleActiveCompleted();
      }
      notifyListeners();
    });
  }

  void skipToCooldown() {
    _cancelTimers();
    _completed = true;
    _setStage(MoroSessionStage.cooldown);
    _notifyResume(null);
  }

  void markLogged() {
    _setStage(MoroSessionStage.log);
    _completed = true;
    _notifyResume(null);
  }

  void continueAfterPause() {
    if (_stage == MoroSessionStage.pause) {
      _cancelPauseTimer();
      _pauseRemaining = Duration.zero;
      _setStage(MoroSessionStage.cooldown);
      _notifyResume(null);
    }
  }

  void abort() {
    _cancelTimers();
    _completed = false;
    _notifyResume(null);
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  void _handleActiveCompleted() {
    _cancelTimers();
    if (autoplay) {
      _pauseRemaining = Duration(seconds: autoplayDelaySeconds);
      _setStage(MoroSessionStage.pause);
      _pauseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final next = _pauseRemaining.inSeconds - 1;
        if (next <= 0) {
          timer.cancel();
          _pauseRemaining = Duration.zero;
          _notifyResume();
          _setStage(MoroSessionStage.cooldown);
          notifyListeners();
        } else {
          _pauseRemaining = Duration(seconds: next);
          _notifyResume();
          notifyListeners();
        }
      });
    } else {
      _pauseRemaining = Duration(seconds: autoplayDelaySeconds);
      _setStage(MoroSessionStage.pause);
      _notifyResume();
    }
  }

  void _setStage(MoroSessionStage stage) {
    _stage = stage;
    notifyListeners();
  }

  void _cancelTimers() {
    _timerSubscription?.cancel();
    _timerSubscription = null;
    _activeToken?.cancel();
    _activeToken = null;
    _cancelDelayTimer();
    _cancelPauseTimer();
  }

  void _cancelDelayTimer() {
    _delayTimer?.cancel();
    _delayTimer = null;
  }

  void _cancelPauseTimer() {
    _pauseTimer?.cancel();
    _pauseTimer = null;
  }

  void _notifyResume([MoroSessionSnapshot? snapshot]) {
    final payload = (snapshot ?? _buildSnapshot())?.toJson();
    onResumeChanged?.call(payload);
  }

  MoroSessionSnapshot? _buildSnapshot() {
    if (_stage == MoroSessionStage.cooldown ||
        _stage == MoroSessionStage.log ||
        _stage == MoroSessionStage.intro) {
      return null;
    }
    return MoroSessionSnapshot(
      stage: _stage,
      repeatIdx: _repeatIdx,
      phaseIdx: _phaseIdx,
      remainingMilliseconds: _stage == MoroSessionStage.delay
          ? _pauseRemaining.inMilliseconds
          : _remaining.inMilliseconds,
    );
  }

  void restoreFrom(MoroSessionSnapshot snapshot) {
    _restoreFromSnapshot(snapshot);
  }

  void _restoreFromSnapshot(MoroSessionSnapshot snapshot) {
    _repeatIdx = snapshot.repeatIdx;
    _phaseIdx = snapshot.phaseIdx;
    _remaining = Duration(milliseconds: snapshot.remainingMilliseconds);
    switch (snapshot.stage) {
      case MoroSessionStage.delay:
        beginDelay(duration: _remaining);
        break;
      case MoroSessionStage.active:
        _remaining = Duration(milliseconds: snapshot.remainingMilliseconds);
        startActive();
        break;
      case MoroSessionStage.pause:
        _pauseRemaining = Duration(milliseconds: snapshot.remainingMilliseconds);
        _setStage(MoroSessionStage.pause);
        if (autoplay && _pauseRemaining > Duration.zero) {
          _handleActiveCompleted();
        }
        break;
      case MoroSessionStage.cooldown:
      case MoroSessionStage.log:
      case MoroSessionStage.intro:
        _setStage(snapshot.stage);
        break;
    }
  }
}
