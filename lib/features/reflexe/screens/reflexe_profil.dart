// lib/features/reflexe/screens/reflexe_profil.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/reflex_profile.dart';
import '../services/reflex_profile_service.dart';

/// Screen displaying saved reflex profiles.
class ReflexeProfilScreen extends StatelessWidget {
  const ReflexeProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gespeicherte Profile')),
      body: FutureBuilder<List<ReflexProfile>>(
        future: context.read<ReflexProfileService>().loadProfiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keine Profile gespeichert'));
          }
          final profiles = snapshot.data!;
          final df = DateFormat.yMMMd();
          return ListView.builder(
            itemCount: profiles.length,
            itemBuilder: (ctx, i) {
              final profile = profiles[i];
              return ExpansionTile(
                title: Text(df.format(profile.createdAt)),
                children: profile.results.entries
                    .map(
                      (e) => ListTile(
                        title: Text(e.key),
                        trailing: Text(
                            '${e.value.yesCount}/${e.value.answeredCount}'),
                      ),
                    )
                    .toList(),
              );
            },
          );
        },
      ),
    );
  }
}
