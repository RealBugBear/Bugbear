import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:bugbear_app/generated/l10n.dart';
import 'package:bugbear_app/providers/locale_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigate(BuildContext context, String routeName) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(routeName);
  }

  void _logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showLanguagePicker(
    BuildContext context,
    LocaleProvider localeProvider,
  ) {
    showDialog<Locale>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: S.delegate.supportedLocales.map((loc) {
            return RadioListTile<Locale>(
              value: loc,
              groupValue: localeProvider.locale,
              title: Text(
                loc.languageCode == 'de'
                    ? S.of(context).german
                    : S.of(context).english,
              ),
              onChanged: (l) {
                Navigator.of(ctx).pop(l);
                if (l != null) {
                  localeProvider.setLocale(l);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              user?.displayName ?? S.of(context).defaultUsername,
            ),
            accountEmail: Text(user?.email ?? S.of(context).defaultEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user != null && (user.displayName?.isNotEmpty ?? false)
                    ? user.displayName![0].toUpperCase()
                    : (user != null && (user.email?.isNotEmpty ?? false)
                        ? user.email![0].toUpperCase()
                        : 'U'),
                style: const TextStyle(fontSize: 24.0, color: Colors.blue),
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: Text(S.of(context).home),
            onTap: () => _navigate(context, '/profile'),
          ),

          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: Text(S.of(context).spinalergalantTrainerTitle),
            onTap: () => _navigate(context, '/spinalergalant'),
          ),

          ListTile(
            leading: const Icon(Icons.accessibility_new),
            title: Text(S.of(context).moroTrainerTitle),
            onTap: () => _navigate(context, '/moro'),
          ),

          ListTile(
            leading: const Icon(Icons.volume_up),
            title: Text(S.of(context).soundSettingsTitle),
            onTap: () => _navigate(context, '/sound-settings'),
          ),

          // Quiz
          ListTile(
            leading: const Icon(Icons.quiz),
            title: Text(S.of(context).quizTitle),
            onTap: () => _navigate(context, '/quiz'),
          ),

          // Reflex-Profil (statt Auswertung)
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Reflex-Profil'),
            onTap: () => _navigate(context, '/saved-results'),
          ),

          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Audio Debug'),
            onTap: () => _navigate(context, '/debug-audio'),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.language),
            title: Text(S.of(context).languageSettings),
            onTap: () => _showLanguagePicker(context, localeProvider),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: Text(S.of(context).logOut),
            onTap: () => _logOut(context),
          ),
        ],
      ),
    );
  }
}
