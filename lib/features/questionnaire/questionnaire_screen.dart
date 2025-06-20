import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:bugbear_app/widgets/app_drawer.dart';

import 'questionnaire_state.dart';
import 'reflexe_profil_temp.dart';

/// Hauptscreen des Fragebogens.
class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  @override
  void initState() {
    super.initState();
    final state = context.read<QuestionnaireState>();
    state.init();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<QuestionnaireState>();

    if (state.isInitialized && state.questions.isEmpty) {
      // Sprache wählen, wenn noch keine Fragen geladen wurden.
      Future.microtask(() {
        if (mounted) _showLanguageDialog();
      });
    }

    if (state.isCompleted) {
      Future.microtask(() {
        if (mounted) _gotoResult();
      });
    }

    final q = state.currentQuestion;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text('${state.currentIndex + 1}/${state.questions.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: state.toggleHelp,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (q != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  q.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: state.currentIndex == 0 ? null : state.previous,
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: state.currentIndex >= state.questions.length - 1
                    ? null
                    : state.next,
              ),
            ),
          ),
          if (state.helpVisible && q != null)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                color: Theme.of(context).dialogTheme.backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.reflexNames.join(', '),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(q.example),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  state.answerCurrent(QuestionAnswer.yes);
                },
                child: const Text('Ja'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  state.answerCurrent(QuestionAnswer.skip);
                },
                child: const Text('X'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  state.answerCurrent(QuestionAnswer.no);
                },
                child: const Text('Nein'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLanguageDialog() async {
    final lang = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Sprache wählen'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'de'),
            child: const Text('Deutsch'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'en'),
            child: const Text('English'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (lang != null) {
      final state = context.read<QuestionnaireState>();
      await state.setLanguage(lang);
    }
  }

  void _gotoResult() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ReflexeProfilTemp()),
    );
  }
}

/// Hilfsfunktion für den Provider in main.dart.
ChangeNotifierProvider<QuestionnaireState> createQuestionnaireProvider() {
  final box = Hive.box('questionnaire_progress');
  return ChangeNotifierProvider<QuestionnaireState>(
    create: (_) => QuestionnaireState(box),
  );
}
