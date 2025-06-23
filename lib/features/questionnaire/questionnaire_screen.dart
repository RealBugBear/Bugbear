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

class _QuestionnaireScreenState extends State<QuestionnaireScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  @override
  void initState() {
    super.initState();
    final state = context.read<QuestionnaireState>();
    state.init();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

    if (state.skipWarningNeeded) {
      Future.microtask(() {
        if (mounted) _showSkipWarning(state);
      });
    }

    final q = state.currentQuestion;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Fragebogen'),
              Tab(text: 'Reflexe-Profil'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: state.toggleHelp,
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildQuestionTab(q, state),
            const ReflexeProfilTemp(),
          ],
        ),
        bottomNavigationBar: _tabController.index == 0
            ? _buildAnswerButtons(state)
            : null,
      ),
    );
  }

  Widget _buildQuestionTab(Question? q, QuestionnaireState state) {
    final progress = state.questions.isEmpty
        ? 0.0
        : (state.currentIndex.clamp(0, state.questions.length) /
            state.questions.length);
    final questionLabel =
        'Frage ${state.currentIndex.clamp(0, state.questions.length) + 1} von ${state.questions.length}';

    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 16),
            Text(questionLabel),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: LinearProgressIndicator(value: progress),
            ),
            const SizedBox(height: 24),
            if (q != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      q.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
          ],
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
    );
  }

  Widget _buildAnswerButtons(QuestionnaireState state) {
    return Padding(
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
    );
  }

  Future<void> _showSkipWarning(QuestionnaireState state) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Zu viele Fragen übersprungen'),
        content: const Text(
            'Du hast bereits mehr als 20% der Fragen übersprungen. '
            'Das Ergebnis könnte dadurch ungenau werden.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    state.markSkipWarningShown();
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
    _tabController.animateTo(1);
  }
}

/// Hilfsfunktion für den Provider in main.dart.
ChangeNotifierProvider<QuestionnaireState> createQuestionnaireProvider() {
  final box = Hive.box('questionnaire_progress');
  return ChangeNotifierProvider<QuestionnaireState>(
    create: (_) => QuestionnaireState(box),
  );
}
