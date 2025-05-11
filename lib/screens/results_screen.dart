import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bugbear_app/models/quiz_model.dart';
import 'package:bugbear_app/generated/l10n.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cats = context.watch<QuizModel>().categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).resultHeader),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              S.of(context).resultHeader,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Alle Kategorien auf einer Seite, kein Scroll
            ...cats.map((cat) {
              final pct = cat.score.clamp(0.0, 100.0);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        cat.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text('${pct.toStringAsFixed(1)} %'),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        value: pct / 100,
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/quiz');
              },
              child: Text(S.of(context).quizTitle),
            ),
          ],
        ),
      ),
    );
  }
}
