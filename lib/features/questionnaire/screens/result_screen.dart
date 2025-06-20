import 'package:flutter/material.dart';

/// Displays the questionnaire result to the user.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ergebnis')),
      body: const Center(
        child: Text('Hier werden die Ergebnisse angezeigt'),
      ),
    );
  }
}
