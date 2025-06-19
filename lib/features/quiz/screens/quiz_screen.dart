import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bugbear_app/widgets/app_drawer.dart';
import '../services/quiz_service.dart';
import '../services/reflex_profile_service.dart';
import '../notifier/quiz_notifier.dart';
import 'reflex_profile_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return ChangeNotifierProvider<QuizNotifier>(
      create: (_) {
        final notifier = QuizNotifier(
          QuizService(locale),
          ReflexProfileService(),
        );
        notifier.load();
        return notifier;
      },
      child: const _QuizContent(),
    );
  }
}

class _QuizContent extends StatelessWidget {
  const _QuizContent();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<QuizNotifier>();
    if (notifier.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = notifier.questions[notifier.index];
    final lang = Localizations.localeOf(context).languageCode;
    final text = question.text[lang] ?? question.text.values.first;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Frage ${notifier.index + 1} von ${notifier.questions.length}'),
            const SizedBox(height: 12),
            Text(text, style: const TextStyle(fontSize: 18)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => notifier.answer(true),
                  child: const Text('Ja'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => notifier.answer(false),
                  child: const Text('Nein'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (notifier.index > 0)
                  OutlinedButton(
                    onPressed: notifier.previous,
                    child: const Text('Zurück'),
                  ),
                ElevatedButton(
                  onPressed: notifier.isLast
                      ? () => _finish(context)
                      : notifier.next,
                  child: Text(notifier.isLast ? 'Fertig' : 'Weiter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finish(BuildContext context) async {
    final notifier = context.read<QuizNotifier>();
    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ergebnis speichern?'),
        content: const Text('Möchtest du dein Profil speichern?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Nur anzeigen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );

    final profile = notifier.buildProfile();
    if (save == true) {
      await notifier.saveProfile();
    }
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReflexProfileScreen(profile: profile),
        ),
      );
    }
  }
}
