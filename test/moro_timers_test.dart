import 'package:flutter_test/flutter_test.dart';
import 'package:free_base/features/training/moro/timers.dart';

void main() {
  test('PhasedMoroTimer duration math incl. rests', () {
    final t = PhasedMoroTimer(
      repeats: 3,
      phasesPerRepeat: 4,
      phaseSeconds: 3 + 2,
      restBetweenRepeatsSeconds: 3,
    );
    expect(t.totalDuration.inSeconds, 66); // (3*4*5) + (2*3)
  });

  test('SimpleMoroTimer duration math incl. rests', () {
    final t = SimpleMoroTimer(
      repeats: 6,
      repeatSeconds: 7 + 3,
      restBetweenRepeatsSeconds: 3,
    );
    expect(t.totalDuration.inSeconds, 75); // (6*10) + (5*3)
  });
}
