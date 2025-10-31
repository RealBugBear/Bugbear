import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:free_base/features/training/moro/moro_models.dart';
import 'package:free_base/features/training/moro/moro_session_controller.dart';

MoroExercise _buildExercise({MoroExerciseType type = MoroExerciseType.simple}) {
  return MoroExercise(
    index: 1,
    title: 'Testübung',
    type: type,
    repeats: type == MoroExerciseType.simple ? 1 : 2,
    phasesPerRepeat: type == MoroExerciseType.simple ? 1 : 4,
    baseSeconds: type == MoroExerciseType.simple ? 1 : 1,
    autoplayDefault: 3,
    goal: '',
    startPosition: '',
    steps: const [],
    cues: const [],
    breath: const MoroBreathPattern(pattern: 'breath'),
    abortRules: const [],
    notes: null,
    tags: const [],
    version: '1.0.0',
    media: const MoroMedia(),
    resumeKey: 'moro_1',
    mediaFallbackImage: null,
    xpReward: 30,
  );
}

void main() {
  group('MoroSessionController', () {
    test('runs through delay -> active -> cooldown for simple exercise', () {
      fakeAsync((async) {
        final controller = MoroSessionController(
          exercise: _buildExercise(),
          offset: 0,
          autoplay: true,
          autoplayDelaySeconds: 1,
        );

        controller.beginDelay(duration: const Duration(milliseconds: 100));
        async.elapse(const Duration(milliseconds: 150));
        expect(controller.stage, MoroSessionStage.active);

        // Let the active phase finish
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 2));
        expect(controller.stage, MoroSessionStage.cooldown);
        expect(controller.isCompleted, isTrue);
      });
    });

    test('emits resume snapshot during active stage and clears after cooldown', () {
      fakeAsync((async) {
        final snapshots = <Map<String, dynamic>?>[];
        final controller = MoroSessionController(
          exercise: _buildExercise(type: MoroExerciseType.phased4x),
          offset: 0,
          autoplay: false,
          autoplayDelaySeconds: 2,
          onResumeChanged: snapshots.add,
        );

        controller.beginDelay(duration: const Duration(milliseconds: 10));
        async.elapse(const Duration(milliseconds: 20));
        expect(controller.stage, MoroSessionStage.active);

        expect(
          snapshots.last?['stage'],
          equals(MoroSessionStage.active.name),
        );

        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));

        expect(controller.stage, MoroSessionStage.pause);
        expect(snapshots.last?['stage'], MoroSessionStage.pause.name);

        controller.continueAfterPause();
        async.flushMicrotasks();

        controller.markLogged();
        expect(controller.stage, MoroSessionStage.log);
        expect(snapshots.last, isNull);
      });
    });
  });
}
