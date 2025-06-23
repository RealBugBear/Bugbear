import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bugbear_app/widgets/app_drawer.dart';

import 'questionnaire_state.dart';

/// Displays questionnaire results with percentages per reflex and allows
/// saving them as a profile.
class QuestionnaireResultScreen extends StatefulWidget {
  const QuestionnaireResultScreen({super.key});

  @override
  State<QuestionnaireResultScreen> createState() => _QuestionnaireResultScreenState();
}

class _QuestionnaireResultScreenState extends State<QuestionnaireResultScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isMainProfile = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _colorForPercent(double p) {
    if (p >= 0.75) return Colors.green;
    if (p >= 0.5) return Colors.orange;
    return Colors.red;
  }

  Future<void> _save(BuildContext context) async {
    final name = _nameController.text.trim().isEmpty
        ? 'Reflexprofil'
        : _nameController.text.trim();
    await context
        .read<QuestionnaireState>()
        .saveResult(name: name, isMainProfile: _isMainProfile);
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/reflexe-profil');
  }

  @override
  Widget build(BuildContext context) {
    final summary = context.watch<QuestionnaireState>().calculateReflexSummary();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Reflexe Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: summary.entries.map((e) {
                  final name = e.key;
                  final yes = e.value[0];
                  final total = e.value[1];
                  final ratio = total == 0 ? 0.0 : yes / total;
                  final percent = (ratio * 100).round();
                  return ListTile(
                    title: Text(name),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: LinearProgressIndicator(
                        value: ratio,
                        color: _colorForPercent(ratio),
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    trailing: Text('$percent%'),
                  );
                }).toList(),
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Profilname',
              ),
            ),
            CheckboxListTile(
              value: _isMainProfile,
              onChanged: (val) {
                setState(() {
                  _isMainProfile = val ?? false;
                });
              },
              title: const Text('Als Hauptprofil festlegen'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _save(context),
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
