import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:free_base/services/app_routes.dart';
import 'package:free_base/services/error_handler.dart';
import 'package:free_base/services/feature_flags.dart';
import 'package:free_base/services/telemetry/telemetry_service.dart';

import 'package:free_base/features/training/notifier/session_notifier.dart';

import 'questionnaire_state.dart';

/// Displays questionnaire results with percentages per reflex and allows
/// saving them as a profile.
class QuestionnaireResultScreen extends StatefulWidget {
  const QuestionnaireResultScreen({super.key});

  @override
  State<QuestionnaireResultScreen> createState() => _QuestionnaireResultScreenState();
}

class _QuestionnaireResultScreenState extends State<QuestionnaireResultScreen> {
  bool _isSaving = false;

  Color _colorForPercent(double p) {
    if (p >= 0.75) return Colors.green;
    if (p >= 0.5) return Colors.orange;
    return Colors.red;
  }

  Future<String?> _promptProfileName() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Profilname'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Profilname'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    controller.dispose();

    return name;
  }

  Future<void> _save(BuildContext context, String name) async {
    setState(() => _isSaving = true);
    final trimmed = name.trim().isEmpty ? 'Reflexprofil' : name.trim();
    final questionnaireState = context.read<QuestionnaireState>();
    final sessionNotifier = context.read<SessionNotifier>();
    final telemetry = context.read<TelemetryService>();
    final featureFlags = context.read<FeatureFlags>();
    try {
      await questionnaireState.saveResult(name: trimmed, context: context);

      sessionNotifier.markOnboardingComplete();
      final locale = Localizations.maybeLocaleOf(context)?.toLanguageTag() ?? 'de';
      await telemetry.logEvent('onboarding_complete', properties: {
        'locale': locale,
        'feature_flag_snapshot': featureFlags.toMap().toString(),
        'connectivity_status': 'unknown',
      });

      if (!context.mounted) return;
      context.goNamed(AppRouteNames.profile);
    } catch (e) {
      if (!context.mounted) return;
      final locale = Localizations.maybeLocaleOf(context);
      final isGerman = locale != null && locale.languageCode.toLowerCase() == 'de';
      final message = ErrorHandler.messageFor(
        e,
        isGerman: isGerman,
        fallback: isGerman
            ? 'Fehler beim Speichern des Profils. Bitte erneut versuchen.'
            : 'Failed to save the profile. Please try again.',
      );
      ErrorHandler.showErrorSnack(context, message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = context.watch<QuestionnaireState>().calculateReflexSummary();

    return Scaffold(
      appBar: AppBar(title: const Text('Ergebnis')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isSaving
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: () async {
                    final name = await _promptProfileName();
                    if (!context.mounted || name == null) return;
                    await _save(context, name);
                  },
                  child: const Text('Speichern'),
                ),
        ),
      ),
    );
  }
}
