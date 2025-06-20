import 'package:flutter/material.dart';

/// Main questionnaire screen.
class QuestionnaireScreen extends StatelessWidget {
  const QuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fragebogen')),
      body: const Center(
        child: Text('Hier folgt der Fragebogen'),
      ),
    );
  }
}
