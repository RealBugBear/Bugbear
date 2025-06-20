import 'package:flutter/material.dart';

/// Screen to choose the app language.
class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sprache wählen')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Deutsch'),
            onTap: () => Navigator.pop(context, 'de'),
          ),
          ListTile(
            title: const Text('English'),
            onTap: () => Navigator.pop(context, 'en'),
          ),
        ],
      ),
    );
  }
}
