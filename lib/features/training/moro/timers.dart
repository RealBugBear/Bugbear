import 'dart:async';

import '../../../services/beeper.dart';
import '../../../services/haptics.dart';

class CancelToken {
  bool _canceled = false;

  void cancel() {
    _canceled = true;
  }

  bool get canceled => _canceled;
}

class PhasedMoroTimer {
  final int repeats;
  final int phasesPerRepeat;
  final int phaseSeconds;
  final int restBetweenRepeatsSeconds;

  const PhasedMoroTimer({
    required this.repeats,
    required this.phasesPerRepeat,
    required this.phaseSeconds,
    this.restBetweenRepeatsSeconds = 3,
  });

  Duration get totalDuration => Duration(
        seconds: (repeats * phasesPerRepeat * phaseSeconds) +
            (repeats <= 1 ? 0 : (repeats - 1) * restBetweenRepeatsSeconds),
      );

  Stream<({int repeatIdx, int phaseIdx, Duration remaining, bool done})> run(
    CancelToken token,
  ) async* {
    final phaseDuration = Duration(seconds: phaseSeconds);
    for (var repeat = 1; repeat <= repeats; repeat++) {
      for (var phase = 1; phase <= phasesPerRepeat; phase++) {
        if (token.canceled) {
          return;
        }
        await Future.wait([Beeper.beep(), Haptics.phase()]);
        final stopwatch = Stopwatch()..start();
        var firstLoop = true;
        while (!token.canceled) {
          final elapsed = stopwatch.elapsed;
          if (elapsed >= phaseDuration) {
            yield (
              repeatIdx: repeat,
              phaseIdx: phase,
              remaining: Duration.zero,
              done: false,
            );
            break;
          }
          final remaining = phaseDuration - elapsed;
          if (!firstLoop) {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            if (token.canceled) {
              return;
            }
          }
          yield (
            repeatIdx: repeat,
            phaseIdx: phase,
            remaining: remaining,
            done: false,
          );
          firstLoop = false;
        }
      }
      if (token.canceled) {
        return;
      }
      if (repeat < repeats) {
        final restDuration = Duration(seconds: restBetweenRepeatsSeconds);
        final restWatch = Stopwatch()..start();
        while (restWatch.elapsed < restDuration) {
          if (token.canceled) {
            return;
          }
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
      }
    }
    yield (
      repeatIdx: repeats,
      phaseIdx: phasesPerRepeat,
      remaining: Duration.zero,
      done: true,
    );
  }
}

class SimpleMoroTimer {
  final int repeats;
  final int repeatSeconds;
  final int restBetweenRepeatsSeconds;

  const SimpleMoroTimer({
    required this.repeats,
    required this.repeatSeconds,
    this.restBetweenRepeatsSeconds = 3,
  });

  Duration get totalDuration => Duration(
        seconds: (repeats * repeatSeconds) +
            (repeats <= 1 ? 0 : (repeats - 1) * restBetweenRepeatsSeconds),
      );

  Stream<({
    int repeatIdx,
    Duration remaining,
    bool done,
    bool justStarted,
    bool justEnded,
  })> run(CancelToken token) async* {
    final repeatDuration = Duration(seconds: repeatSeconds);
    for (var repeat = 1; repeat <= repeats; repeat++) {
      if (token.canceled) {
        return;
      }
      await Future.wait([Beeper.beep(), Haptics.repStart()]);
      final stopwatch = Stopwatch()..start();
      var firstLoop = true;
      while (!token.canceled) {
        final elapsed = stopwatch.elapsed;
        if (elapsed >= repeatDuration) {
          yield (
            repeatIdx: repeat,
            remaining: Duration.zero,
            done: false,
            justStarted: false,
            justEnded: false,
          );
          break;
        }
        final remaining = repeatDuration - elapsed;
        if (!firstLoop) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          if (token.canceled) {
            return;
          }
        }
        yield (
          repeatIdx: repeat,
          remaining: remaining,
          done: false,
          justStarted: firstLoop,
          justEnded: false,
        );
        firstLoop = false;
      }
      if (token.canceled) {
        return;
      }
      await Future.wait([Beeper.beep(), Haptics.repEnd()]);
      yield (
        repeatIdx: repeat,
        remaining: Duration.zero,
        done: false,
        justStarted: false,
        justEnded: true,
      );
      if (repeat < repeats) {
        final restDuration = Duration(seconds: restBetweenRepeatsSeconds);
        final restWatch = Stopwatch()..start();
        while (restWatch.elapsed < restDuration) {
          if (token.canceled) {
            return;
          }
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
      }
    }
    yield (
      repeatIdx: repeats,
      remaining: Duration.zero,
      done: true,
      justStarted: false,
      justEnded: false,
    );
  }
}
