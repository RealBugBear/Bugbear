import 'package:bugbear/features/training/moro/pre_check_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Weiter zum Training ist erst aktiv, wenn alle Vorbereitungspunkte bestätigt sind',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MoroPreCheckScreen(),
        ),
      );

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Weiter zum Training');

      ElevatedButton button = tester.widget(buttonFinder);
      expect(button.onPressed, isNull);

      final checklistFinder = find.byType(CheckboxListTile);
      final itemCount = checklistFinder.evaluate().length;

      for (var index = 0; index < itemCount; index++) {
        await tester.tap(checklistFinder.at(index));
        await tester.pumpAndSettle();
      }

      button = tester.widget(buttonFinder);
      expect(button.onPressed, isNotNull);
    },
  );
}
