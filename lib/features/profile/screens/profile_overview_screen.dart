import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:free_base/widgets/app_drawer.dart';
import '../models/reflex_profile.dart';
import '../services/profile_service.dart';
import '../../calendar/widgets/golden_day_banner.dart';

class ProfileOverviewScreen extends StatelessWidget {
  const ProfileOverviewScreen({super.key});

  Future<void> _deleteProfile(BuildContext context, String userId, String profileId, bool isMain) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Profil löschen?'),
        content: const Text('Möchtest du dieses Profil unwiderruflich löschen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Löschen')),
        ],
      ),
    );
    if (confirm == true) {
      final service = ProfileService();
      await service.deleteProfile(userId, profileId);
      if (isMain) {
        await service.setMainProfile(userId, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Nicht angemeldet')));
    }
    final service = ProfileService();
    return StreamBuilder<String?>(
      stream: service.watchMainProfileId(uid),
      builder: (context, mainSnap) {
        if (mainSnap.hasError) {
          final msg = FirebaseAuth.instance.currentUser == null
              ? 'Nicht angemeldet'
              : mainSnap.error.toString();
          return Scaffold(body: Center(child: Text(msg)));
        }
        final mainId = mainSnap.data;
        return StreamBuilder<List<ReflexProfile>>(
          stream: service.watchProfiles(uid),
          builder: (context, snap) {
            if (snap.hasError) {
              final msg = FirebaseAuth.instance.currentUser == null
                  ? 'Nicht angemeldet'
                  : snap.error.toString();
              return Scaffold(body: Center(child: Text(msg)));
            }
            if (!snap.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            final profiles = snap.data!;
            return Scaffold(
              drawer: const AppDrawer(),
              appBar: AppBar(title: const Text('Reflexprofile')),
              body: Column(
                children: [
                  Expanded(
                    child: profiles.isEmpty
                        ? const Center(child: Text('Keine Profile vorhanden'))
                        : ListView.builder(
                            itemCount: profiles.length,
                            itemBuilder: (ctx, i) {
                              final p = profiles[i];
                              final isMain = p.id == mainId;
                              return ListTile(
                                leading: isMain
                                    ? const Icon(Icons.star, color: Colors.orange)
                                    : const Icon(Icons.person),
                                title: Text(p.name),
                                subtitle: Text(DateFormat('dd.MM.yyyy').format(p.createdAt)),
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/reflexe-profil/detail',
                                  arguments: p,
                                ),

                                tileColor: isMain
                                    ? Colors.orange
                                        .withAlpha((0.2 * 255).round())
                                    : null,

                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!isMain)
                                      IconButton(
                                        icon: const Icon(Icons.star_border),
                                        onPressed: () => service.setMainProfile(uid, p.id),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deleteProfile(context, uid, p.id, isMain),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  if (mainId != null)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: GoldenDayBanner(),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/questionnaire'),
                      child: const Text('Neues Quiz starten'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
