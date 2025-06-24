import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:bugbear_app/widgets/app_drawer.dart';

import 'questionnaire_state.dart';

/// Einf\u00fchrungsseite f\u00fcr den Fragebogen mit DSGVO-Hinweis.
class QuizIntroScreen extends StatelessWidget {
  const QuizIntroScreen({super.key});

  Future<void> _startQuiz(BuildContext context) async {
    final box = Hive.box('questionnaire_progress');
    final state = context.read<QuestionnaireState>();

    // Ensure questions are loaded to determine their count
    if (!state.isInitialized) {
      await state.init();
    }
    if (!context.mounted) return;

    final storedIndex = box.get('index', defaultValue: 0) as int;
    final questionCount = state.questions.length;

    if (storedIndex >= questionCount && questionCount > 0) {
      await box.clear();
      if (!context.mounted) return;
      state.resetState();
    }

    bool continueQuiz = true;
    if (box.isNotEmpty) {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Fragebogen fortsetzen?'),
          content: const Text(
            'Es wurde ein unvollst\u00e4ndiger Fragebogen gefunden. M\u00f6chtest du fortsetzen oder neu starten?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Neu starten'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Fortsetzen'),
            ),
          ],
        ),
      );
      if (!context.mounted) return;
      continueQuiz = result ?? false;
      if (!continueQuiz) {
        await box.clear();
        if (context.mounted) {
          context.read<QuestionnaireState>().resetState();
        }
      }
    }

    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/questionnaire/questions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Fragebogen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Mit Start des Quiz stimmst du der Verarbeitung deiner Daten gem\u00e4\u00df DSGVO zu.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _startQuiz(context),
              child: const Text('Quiz starten'),
            ),
          ],
        ),
      ),
    );
  }
}
