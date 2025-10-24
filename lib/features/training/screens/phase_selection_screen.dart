import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/features/training/services/exercise_repository.dart';
import 'package:free_base/widgets/info_card.dart';

class PhaseSelectionScreen extends StatelessWidget {
  const PhaseSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phases = context.read<ExerciseRepository>().phaseIds;
    return Scaffold(
      appBar: AppBar(title: const Text('Phase auswählen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const InfoCard(
            title: 'Phase wählen',
            description:
                'Wähle die Phase, die zu deinem aktuellen Trainingsplan passt. Jede Phase baut aufeinander auf und bringt neue Übungen sowie angepasste Wiederholungsziele mit sich.',
            icon: Icons.flag_outlined,
          ),
          const SizedBox(height: 16),
          ...phases.map((id) {
            return Card(
              child: ListTile(
                title: Text('Phase $id'),
                subtitle: const Text(
                  'Zeigt dir die passenden Übungen und Tagesziele an.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.read<SessionNotifier>().changePhase(id);
                  Navigator.of(context).pop();
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
