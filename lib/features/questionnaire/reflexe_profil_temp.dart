import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bugbear_app/widgets/app_drawer.dart';

import 'questionnaire_state.dart';

/// Temporäre Ergebnisanzeige für die Reflexe nach dem Fragebogen.
class ReflexeProfilTemp extends StatelessWidget {
  const ReflexeProfilTemp({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = context.watch<QuestionnaireState>().calculateReflexSummary();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Reflexe Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Ergebnisse speichern?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Nein'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Ja'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await context.read<QuestionnaireState>().saveResult();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/reflexe-profil');
                }
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: summary.entries.map((e) {
          final name = e.key;
          final yes = e.value[0];
          final total = e.value[1];
          return ListTile(
            title: Text(name),
            trailing: Text('$yes/$total'),
          );
        }).toList(),
      ),
    );
  }
}
