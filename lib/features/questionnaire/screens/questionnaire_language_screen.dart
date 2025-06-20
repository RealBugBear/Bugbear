import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bugbear_app/features/questionnaire/notifier/questionnaire_notifier.dart';

class QuestionnaireLanguageScreen extends StatelessWidget {
  const QuestionnaireLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<QuestionnaireNotifier>();
    return Scaffold(
      appBar: AppBar(title: const Text('Questionnaire Language')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await notifier.start('en');
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/questionnaire');
                }
              },
              child: const Text('English'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await notifier.start('de');
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/questionnaire');
                }
              },
              child: const Text('Deutsch'),
            ),
          ],
        ),
      ),
    );
  }
}
