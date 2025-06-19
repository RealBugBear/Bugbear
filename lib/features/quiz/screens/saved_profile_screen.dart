import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/reflex_profile_service.dart';
import '../models/reflex_profile.dart';
import 'reflex_profile_screen.dart';

class SavedProfileScreen extends StatelessWidget {
  const SavedProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<ReflexProfileService>();
    return FutureBuilder<ReflexProfile?>(
      future: service.load(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            appBar: AppBar(title: const Text('Reflexprofil')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final profile = snap.data;
        if (profile == null) {
          return const Scaffold(
            appBar: AppBar(title: const Text('Reflexprofil')),
            body: const Center(child: Text('Kein Profil gespeichert.')),
          );
        }
        return ReflexProfileScreen(profile: profile);
      },
    );
  }
}
