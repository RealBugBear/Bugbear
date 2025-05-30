import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bugbear_app/features/training/services/exercise_repository.dart';
import 'package:bugbear_app/features/training/notifier/session_notifier.dart';

class PhaseSelectionDialog extends StatelessWidget {
  const PhaseSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final phases = context.read<ExerciseRepository>().phaseIds;
    return SimpleDialog(
      title: const Text('Phase auswählen'),
      children: phases.map((phaseId) {
        return SimpleDialogOption(
          onPressed: () {
            context.read<SessionNotifier>().changePhase(phaseId);
            Navigator.of(context).pop();
          },
          child: Text('Phase $phaseId'),
        );
      }).toList(),
    );
  }
}
