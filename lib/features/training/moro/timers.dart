import 'dart:async';
import '../../../services/beeper.dart';
import '../../../services/haptics.dart';

class CancelToken {
  bool _canceled = false;
  void cancel() => _canceled = true;
  bool get canceled => _canceled;
}

/// Exercises 1–5 (phased4x): 3 repeats, each repeat has 4 phases of (3+offset)s.
/// 3s rest between repeats. Beep + haptic at *each phase start*.
class PhasedMoroTimer {
  final int repeats;                 // 3
  final int phasesPerRepeat;         // 4
  final int phaseSeconds;            // 3 + offset
  final int restBetweenRepeatsSeconds;   // 3  <-- name matches tests

  PhasedMoroTimer({
    required this.repeats,
    required this.phasesPerRepeat,
    required this.phaseSeconds,
    this.restBetweenRepeatsSeconds = 3,
  });

  /// Total wall-clock time including rests.
  Duration get totalDuration {
    final active = repeats * phasesPerRepeat * phaseSeconds;
    final rests = (repeats - 1) * restBetweenRepeatsSeconds;
    return Duration(seconds: active + rests);
  }

  Stream<({int repeatIdx, int phaseIdx, Duration remaining, bool done})> run(CancelToken token) async* {
    for (var r = 1; r <= repeats; r++) {
      for (var p = 1; p <= phasesPerRepeat; p++) {
        if (token.canceled) return;
        await Beeper.beep();
        await Haptics.phase();
        final dur = Duration(seconds: phaseSeconds);
        final sw = Stopwatch()..start();
        while (sw.elapsed < dur) {
          if (token.canceled) return;
          yield (repeatIdx: r, phaseIdx: p, remaining: dur - sw.elapsed, done: false);
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      }
      if (r < repeats) {
        final rest = Duration(seconds: restBetweenRepeatsSeconds);
        final rsw = Stopwatch()..start();
        while (rsw.elapsed < rest) {
          if (token.canceled) return;
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
      }
    }
    yield (repeatIdx: repeats, phaseIdx: phasesPerRepeat, remaining: Duration.zero, done: true);
  }
}

/// Exercises 6–7 (simple): 6 repeats of (7+offset)s, 3s rest between repeats.
/// Beep + haptic at *repeat start & end* only.
class SimpleMoroTimer {
  final int repeats;                     // 6
  final int repeatSeconds;               // 7 + offset
  final int restBetweenRepeatsSeconds;   // 3  <-- name matches tests

  SimpleMoroTimer({
    required this.repeats,
    required this.repeatSeconds,
    this.restBetweenRepeatsSeconds = 3,
  });

  /// Total wall-clock time including rests.
  Duration get totalDuration {
    final active = repeats * repeatSeconds;
    final rests = (repeats - 1) * restBetweenRepeatsSeconds;
    return Duration(seconds: active + rests);
  }

  Stream<({int repeatIdx, Duration remaining, bool done, bool justStarted, bool justEnded})> run(CancelToken token) async* {
    for (var r = 1; r <= repeats; r++) {
      if (token.canceled) return;
      await Beeper.beep();
      await Haptics.repStart();
      final dur = Duration(seconds: repeatSeconds);
      final sw = Stopwatch()..start();
      var first = true;
      while (sw.elapsed < dur) {
        if (token.canceled) return;
        yield (repeatIdx: r, remaining: dur - sw.elapsed, done: false, justStarted: first, justEnded: false);
        first = false;
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      await Beeper.beep();
      await Haptics.repEnd();
      yield (repeatIdx: r, remaining: Duration.zero, done: false, justStarted: false, justEnded: true);

      if (r < repeats) {
        final rest = Duration(seconds: restBetweenRepeatsSeconds);
        final rsw = Stopwatch()..start();
        while (rsw.elapsed < rest) {
          if (token.canceled) return;
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
      }
    }
    yield (repeatIdx: repeats, remaining: Duration.zero, done: true, justStarted: false, justEnded: false);
  }
}
