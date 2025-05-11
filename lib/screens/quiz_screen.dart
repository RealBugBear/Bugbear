import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bugbear_app/models/quiz_model.dart';
import 'package:bugbear_app/generated/l10n.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      final lang = Localizations.localeOf(context).languageCode;
      context.read<QuizModel>().loadAll(lang);
    }
  }

  Future<void> _onAnswer(bool yes) async {
    final quizModel = context.read<QuizModel>();
    quizModel.answerCurrent(yes);

    final isLast = quizModel.currentIndex + 1 == quizModel.questions.length;
    if (!isLast) {
      quizModel.next(context);
      return;
    }

    // Finale Auswertung
    quizModel.calculateScores();

    // Frage zum Speichern
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).quizTitle),
        content: Text('Möchten Sie das Ergebnis speichern?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(S.of(context).no),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(S.of(context).yes),
          ),
        ],
      ),
    );

    if (save == true) {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = quizModel.categories
          .map((c) => {'id': c.id, 'name': c.name, 'score': c.score})
          .toList();
      await prefs.setString('savedResults', jsonEncode(jsonList));
    }

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/results');
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizModel = context.watch<QuizModel>();

    if (quizModel.questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final current = quizModel.questions[quizModel.currentIndex];
    final lang = Localizations.localeOf(context).languageCode;
    final questionText = current.text[lang] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${S.of(context).quizTitle} ${quizModel.currentIndex + 1}/${quizModel.questions.length}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (quizModel.currentIndex + 1) /
                  quizModel.questions.length,
              minHeight: 8,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surface
                  .withAlpha((0.3 * 255).round()),
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              S.of(context).quizProgress(
                quizModel.currentIndex + 1,
                quizModel.questions.length,
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              questionText,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _onAnswer(true),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.secondary,
                  ),
                  child: Text(S.of(context).yes),
                ),
                ElevatedButton(
                  onPressed: () => _onAnswer(false),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.secondary,
                  ),
                  child: Text(S.of(context).no),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
