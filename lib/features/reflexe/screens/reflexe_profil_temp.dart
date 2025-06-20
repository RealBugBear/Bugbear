import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reflex_profile.dart';
import '../services/reflex_profile_service.dart';

/// Temporary screen showing reflex result counts.
class ReflexeProfilTempScreen extends StatelessWidget {
  /// Map of reflex name -> result counts.
  final Map<String, ReflexResult> results;

  const ReflexeProfilTempScreen({super.key, required this.results});

  Future<void> _save(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Profil speichern?'),
        content: const Text('Möchtest du dieses Reflexprofil speichern?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<ReflexProfileService>().saveProfile(results);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil gespeichert')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reflexprofil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _save(context),
          ),
        ],
      ),
      body: ListView(
        children: results.entries
            .map(
              (e) => ListTile(
                title: Text(e.key),
                trailing:
                    Text('${e.value.yesCount}/${e.value.answeredCount}'),
              ),
            )
            .toList(),
      ),
    );
  }
}
