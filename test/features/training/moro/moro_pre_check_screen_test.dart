import 'package:bugbear/features/training/moro/pre_check_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Weiter zum Training ist direkt verfügbar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MoroPreCheckScreen(),
      ),
    );

    expect(find.byType(CheckboxListTile), findsNothing);

    final buttonFinder = find.widgetWithText(FilledButton, 'Weiter zum Training');
    final button = tester.widget<FilledButton>(buttonFinder);

    expect(button.onPressed, isNotNull);
  });
}
