import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:free_base/features/training/services/exercise_repository.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/widgets/app_drawer.dart';

class PhaseSelectionScreen extends StatelessWidget {
  const PhaseSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phases = context.read<ExerciseRepository>().phaseIds;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Phase auswählen')),
      body: ListView.builder(
        itemCount: phases.length,
        itemBuilder: (ctx, i) {
          final id = phases[i];
          return ListTile(
            title: Text('Phase $id'),
            onTap: () {
              context.read<SessionNotifier>().changePhase(id);
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}
