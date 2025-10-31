import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/onboarding/state/consent_notifier.dart';
import 'package:free_base/services/app_routes.dart';
import 'package:free_base/services/feature_flags.dart';
import 'package:free_base/services/telemetry/telemetry_service.dart';
import 'package:free_base/widgets/fallback_scaffold.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _loggedShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loggedShown) {
      _loggedShown = true;
      final telemetry = context.read<TelemetryService>();
      final locale = Localizations.maybeLocaleOf(context)?.toLanguageTag() ?? 'de';
      telemetry.logEvent('consent_shown', properties: {
        'locale': locale,
      });
    }
  }

  Future<void> _acceptConsent() async {
    final locale = Localizations.maybeLocaleOf(context)?.toLanguageTag() ?? 'de';
    final consentNotifier = context.read<ConsentNotifier>();
    await consentNotifier.accept(locale: locale);

    final telemetry = context.read<TelemetryService>();
    await telemetry.logEvent('consent_accepted', properties: {
      'locale': locale,
    });

    if (!mounted) return;
    final featureFlags = context.read<FeatureFlags>();
    final targetRoute = featureFlags.consentRequired
        ? AppRouteNames.dashboard
        : AppRouteNames.training;
    context.goNamed(targetRoute);
  }

  void _showDeclineInfo() {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Du musst den Datenschutzbestimmungen zustimmen, um Corejourney zu nutzen.',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: theme.colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context)?.languageCode.toLowerCase();
    final isGerman = locale == 'de';

    return FallbackScaffold(
      title: isGerman ? 'Datenschutz' : 'Privacy',
      headline: isGerman ? 'Einwilligung erforderlich' : 'Consent required',
      message: isGerman
          ? 'Um Corejourney zu nutzen, benötigen wir deine Zustimmung zur vorläufigen Datenschutzerklärung. Die finalen Texte folgen in einer späteren Version.'
          : 'To continue using Corejourney you need to accept the placeholder privacy agreement. The final copy will arrive in a future update.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isGerman ? 'Wichtige Punkte' : 'Key points',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _ConsentBullet(
            text: isGerman
                ? 'Deine Trainingsfortschritte werden lokal gespeichert und bei Verbindung synchronisiert.'
                : 'Your training progress is stored locally and synchronised once you are online.',
          ),
          _ConsentBullet(
            text: isGerman
                ? 'Telemetry-Events helfen uns, App-Start und Onboarding technisch zu überwachen.'
                : 'Telemetry events allow us to understand app launches and onboarding completions.',
          ),
          _ConsentBullet(
            text: isGerman
                ? 'Du kannst den Fragebogen jederzeit pausieren oder neu starten.'
                : 'You can pause or restart the questionnaire at any time.',
          ),
        ],
      ),
      primaryActionLabel:
          isGerman ? 'Zustimmen und fortfahren' : 'Accept and continue',
      onPrimaryAction: _acceptConsent,
      secondaryActionLabel: isGerman ? 'Ablehnen' : 'Decline',
      onSecondaryAction: _showDeclineInfo,
      icon: Icons.privacy_tip_outlined,
    );
  }
}

class _ConsentBullet extends StatelessWidget {
  final String text;

  const _ConsentBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
