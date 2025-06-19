import 'package:flutter/material.dart';
import 'package:bugbear_app/widgets/app_drawer.dart';
import '../models/reflex_profile.dart';
import '../services/quiz_service.dart';
import '../models/reflex_category.dart';

class ReflexProfileScreen extends StatelessWidget {
  final ReflexProfile profile;
  const ReflexProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return FutureBuilder<List<ReflexCategory>>(
      future: QuizService(locale).loadCategories(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text('Profil')),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final names = {for (var c in snap.data!) c.id: c.name};
        return Scaffold(
          drawer: const AppDrawer(),
          appBar: AppBar(title: const Text('Reflexprofil')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: profile.scores.entries.map((e) {
              final name = names[e.key] ?? e.key;
              final percent = e.value.toStringAsFixed(0);
              return ListTile(
                title: Text(name),
                trailing: Text('$percent %'),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
