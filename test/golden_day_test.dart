import 'package:flutter_test/flutter_test.dart';
import 'package:free_base/features/calendar/services/golden_day_service.dart';

void main() {
  final service = GoldenDayService();

  group('GoldenDayService', () {
    test('zero sessions extend the phase significantly', () {
      final start = DateTime(2024, 1, 1);
      final result = service.calculateGoldenDay(start, {0: 0});
      expect(result, start.add(const Duration(days: 40)));
    });

    test('no weeks -> first golden day after 6 days', () {
      final start = DateTime(2024, 1, 1); // monday
      final result = service.calculateGoldenDay(start, {});
      expect(result, start.add(const Duration(days: 6)));
    });

    test('six sessions keep the baseline schedule', () {
      final start = DateTime(2024, 1, 1);
      final result = service.calculateGoldenDay(start, {0: 6});
      expect(result, start.add(const Duration(days: 13)));
    });

    test('missing sessions shift later', () {
      final start = DateTime(2024, 1, 1);
      final result = service.calculateGoldenDay(start, {0: 5});
      expect(result, start.add(const Duration(days: 14)));
    });

    test('more than six sessions shift earlier', () {
      final start = DateTime(2024, 1, 1);
      final result = service.calculateGoldenDay(start, {0: 7});
      expect(result, start.add(const Duration(days: 12)));
    });

    test('multiple weeks accumulate shift', () {
      final start = DateTime(2024, 1, 1);
      final result = service.calculateGoldenDay(start, {0: 6, 1: 4});
      expect(result, start.add(const Duration(days: 22)));
    });
  });
}
