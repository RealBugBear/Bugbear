import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:free_base/services/app_routes.dart';
import 'package:free_base/services/feature_flags.dart';

import '../../calendar/widgets/golden_day_banner.dart';
import '../models/reflex_profile.dart';
import '../services/profile_service.dart';

class ProfileOverviewScreen extends StatelessWidget {
  const ProfileOverviewScreen({super.key});

  Color _avatarColor(String? itemId, ThemeData theme) {
    if (itemId == null || itemId.isEmpty) {
      return theme.colorScheme.secondary.withOpacity(0.2);
    }
    final hash = itemId.codeUnits.fold<int>(0, (acc, code) => acc + code);
    final hue = (hash % 360).toDouble();
    return HSVColor.fromAHSV(1, hue, 0.4, 0.8).toColor();
  }

  Widget _buildAvatarPreview(ReflexProfile profile, ThemeData theme, {double radius = 24}) {
    final color = _avatarColor(profile.avatarItemId, theme);
    final brightness = ThemeData.estimateBrightnessForColor(color);
    final iconColor = brightness == Brightness.dark ? Colors.white : Colors.black87;
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Icon(
        Icons.person,
        color: iconColor,
      ),
    );
  }

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
    final flags = context.watch<FeatureFlags>();
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
            final showCommunityLinks =
                flags.forumEnabled || flags.achievementsEnabled;
            final theme = Theme.of(context);
            ReflexProfile? mainProfile;
            if (mainId != null) {
              try {
                mainProfile = profiles.firstWhere((p) => p.id == mainId);
              } catch (_) {
                mainProfile = profiles.isNotEmpty ? profiles.first : null;
              }
            }
            mainProfile ??= profiles.isNotEmpty ? profiles.first : null;
            return Scaffold(
              appBar: AppBar(
                title: const Text('Reflexprofile'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Einstellungen',
                    onPressed: () => context.pushNamed(AppRouteNames.settings),
                  ),
                ],
              ),
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
                              final preview = _buildAvatarPreview(p, theme);
                              return ListTile(
                                leading: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    preview,
                                    if (isMain)
                                      const Positioned(
                                        right: -2,
                                        bottom: -2,
                                        child: Icon(
                                          Icons.star,
                                          color: Colors.orange,
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                                title: Text(p.name),
                                subtitle: Text(DateFormat('dd.MM.yyyy').format(p.createdAt)),
                                onTap: () => context.pushNamed(
                                  AppRouteNames.profileDetail,
                                  extra: p,
                                ),

                                tileColor: isMain
                                    ? Colors.orange
                                        .withAlpha((0.2 * 255).round())
                                    : null,

                                trailing: PopupMenuButton<_ProfileAction>(
                                  onSelected: (action) async {
                                    switch (action) {
                                      case _ProfileAction.setMain:
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Profil wechseln?'),
                                            content: Text(
                                                'Möchtest du "${p.name}" als aktives Profil nutzen?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, false),
                                                child: const Text('Abbrechen'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, true),
                                                child: const Text('Ja'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await service.setMainProfile(uid, p.id);
                                        }
                                        break;
                                      case _ProfileAction.openShop:
                                        if (!context.mounted) return;
                                        context.pushNamed(AppRouteNames.profileShop, extra: p);
                                        break;
                                      case _ProfileAction.delete:
                                        await _deleteProfile(context, uid, p.id, isMain);
                                        break;
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    if (!isMain)
                                      const PopupMenuItem(
                                        value: _ProfileAction.setMain,
                                        child: Text('Als Hauptprofil nutzen'),
                                      ),
                                    PopupMenuItem(
                                      value: _ProfileAction.openShop,
                                      child: Row(
                                        children: const [
                                          Icon(Icons.style, size: 18),
                                          SizedBox(width: 8),
                                          Text('Profil anpassen'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: _ProfileAction.delete,
                                      child: Text('Löschen'),
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
                          context.pushNamed(AppRouteNames.questionnaireIntro),
                      child: const Text('Neues Quiz starten'),
                    ),
                  ),
                  if (mainProfile != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.pushNamed(AppRouteNames.profileDetail, extra: mainProfile),
                            icon: const Icon(Icons.insights_outlined),
                            label: const Text('Ergebnisse anzeigen'),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () =>
                                context.pushNamed(AppRouteNames.profileShop, extra: mainProfile),
                            icon: const Icon(Icons.style),
                            label: const Text('Profil anpassen'),
                          ),
                        ],
                      ),
                    ),
                  if (showCommunityLinks)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (flags.forumEnabled)
                            OutlinedButton.icon(
                              onPressed: () =>
                                  context.pushNamed(AppRouteNames.forum),
                              icon: const Icon(Icons.forum_outlined),
                              label: const Text('Zum Forum (Beta)'),
                            ),
                          if (flags.forumEnabled && flags.achievementsEnabled)
                            const SizedBox(height: 12),
                          if (flags.achievementsEnabled)
                            OutlinedButton.icon(
                              onPressed: () =>
                                  context.pushNamed(AppRouteNames.achievements),
                              icon: const Icon(Icons.emoji_events_outlined),
                              label: const Text('Erfolge ansehen'),
                            ),
                        ],
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

enum _ProfileAction { setMain, openShop, delete }
