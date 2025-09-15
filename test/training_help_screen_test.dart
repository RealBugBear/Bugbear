import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:free_base/features/training/services/exercise_repository.dart';
import 'package:free_base/features/training/screens/training_help_screen.dart';

void main() {
  testWidgets('shows buttons for each exercise', (tester) async {
    const phase = '1';
    final repo = ExerciseRepository();
    final count = repo.getExercisesForPhase(phase).length;

    await tester.pumpWidget(
      Provider<ExerciseRepository>.value(
        value: repo,
        child: const MaterialApp(
          home: TrainingHelpScreen(phaseId: phase),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(ElevatedButton), findsNWidgets(count));
  });
}
