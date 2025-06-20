import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bugbear_app/widgets/app_drawer.dart';
import 'package:bugbear_app/features/questionnaire/notifier/questionnaire_notifier.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  bool _showInfo = false;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<QuestionnaireNotifier>();
    final q = notifier.currentQuestion;
    if (q == null) {
      // Finished
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/reflexe_profil_temp');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final total = notifier.questions.length;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text('${q.id}/$total'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              setState(() => _showInfo = !_showInfo);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: notifier.index > 0 ? notifier.previous : null,
                    ),
                    Expanded(
                      child: Text(
                        q.text,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: notifier.index < total - 1 ? notifier.next : null,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await notifier.answer('Ja');
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 60),
                      ),
                      child: const Text('Ja'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await notifier.answer('X');
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 60),
                      ),
                      child: const Text('X'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await notifier.answer('Nein');
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 60),
                      ),
                      child: const Text('Nein'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_showInfo)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Material(
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(q.reflexNames.join(', '),
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(q.example),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() => _showInfo = false);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
