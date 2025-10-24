import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:free_base/features/training/moro/moro_speed_store.dart';
import 'package:free_base/features/training/moro/timers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Moro timer durations', () {
    test('PhasedMoroTimer duration math includes rests and offset seconds', () {
      const offset = 2;
      final timer = PhasedMoroTimer(
        repeats: 3,
        phasesPerRepeat: 4,
        phaseSeconds: 3 + offset,
        restBetweenRepeatsSeconds: 3,
      );
      expect(timer.totalDuration, const Duration(seconds: 66));
    });

    test('SimpleMoroTimer duration math includes rests and offset seconds', () {
      const offset = 3;
      final timer = SimpleMoroTimer(
        repeats: 6,
        repeatSeconds: 7 + offset,
        restBetweenRepeatsSeconds: 3,
      );
      expect(timer.totalDuration, const Duration(seconds: 75));
    });
  });

  group('MoroSpeedStore', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('moro_speed_store_test');
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('persists and clamps offsets per exercise', () async {
      await MoroSpeedStore.setOffsetForExercise(3, 5);
      expect(await MoroSpeedStore.getOffsetForExercise(3), 3);

      await MoroSpeedStore.setOffsetForExercise(3, -1);
      expect(await MoroSpeedStore.getOffsetForExercise(3), 0);

      await MoroSpeedStore.setOffsetForExercise(2, 1);
      expect(await MoroSpeedStore.getOffsetForExercise(2), 1);

      final box = await Hive.openBox('moro_speed_offsets');
      await box.put('offsets', {'5': 42});
      expect(await MoroSpeedStore.getOffsetForExercise(5), 3);
    });
  });
}
