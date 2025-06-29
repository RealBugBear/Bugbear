import 'package:flutter/material.dart';
import 'package:bugbear_app/features/training/screens/phase_selection_screen.dart';
import 'package:bugbear_app/features/training/screens/training_help_screen.dart';

/// TrainingHeader zeigt in der oberen Leiste:
/// - das automatische Hamburger-Icon (öffnet den Drawer)
/// - den aktuellen Phasen-Namen (klickbar: öffnet PhaseSelectionScreen)
/// - ein Hilfesymbol (öffnet ein Overlay mit Erklärungen)
class TrainingHeader extends StatelessWidget implements PreferredSizeWidget {
  final String phaseName;
  final String phaseId;

  const TrainingHeader({
    super.key,
    required this.phaseName,
    required this.phaseId,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Flutter zeigt automatisch das Hamburger-Icon, wenn ein Drawer vorhanden ist.
      title: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PhaseSelectionScreen(),
            ),
          );
        },
        child: Text(
          phaseName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline, // als Link kenntlich
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TrainingHelpScreen(phaseId: phaseId),
              ),
            );
          },
          tooltip: 'Hilfe anzeigen',
        ),
      ],
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
    );
  }
}
