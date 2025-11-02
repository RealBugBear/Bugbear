import 'package:flutter/material.dart';

class MoroPreCheckResult {
  final bool autoplayEnabled;
  final int autoplayDelaySeconds;

  const MoroPreCheckResult({
    required this.autoplayEnabled,
    required this.autoplayDelaySeconds,
  });
}

class MoroPreCheckScreen extends StatefulWidget {
  const MoroPreCheckScreen({super.key});

  @override
  State<MoroPreCheckScreen> createState() => _MoroPreCheckScreenState();
}

class _MoroPreCheckScreenState extends State<MoroPreCheckScreen> {
  static const _checklistItems = [
    (
      'Ich bin nüchtern oder habe höchstens einen leichten Snack gegessen.',
      null,
    ),
    (
      'Ich trage lockere Kleidung und habe ausreichend Platz für das Training.',
      null,
    ),
    (
      'Ich habe Wasser bereitgestellt.',
      null,
    ),
    (
      'Optional: Ich habe eine binaurale Musikspur vorbereitet (empfohlen).',
      'Binaurale Musik kann die Konzentration unterstützen, ist aber nicht verpflichtend.',
    ),
    (
      'Optional: Ich habe meine eigene Musik oder Playlist vorbereitet.',
      'Falls gewünscht, kannst du mit deiner eigenen Musik trainieren.',
    ),
    (
      'Optional: Ich kenne den Autoplay-Modus – die Übungen wechseln automatisch nach der Pause.',
      'Der Autoplay-Modus kann jederzeit während des Trainings angepasst werden.',
    ),
  ];

  bool _autoplay = true;
  int _delay = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vorbereitung Moro-Training')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bitte bestätige deine Vorbereitungsschritte',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._checklistItems.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(entry.$1),
                  trailing: entry.$2 == null
                      ? null
                      : Tooltip(
                          message: entry.$2!,
                          child: const Icon(Icons.help_outline),
                        ),
                ),
              ),
            ),
            const Divider(height: 32),
            SwitchListTile.adaptive(
              value: _autoplay,
              onChanged: (v) => setState(() => _autoplay = v),
              title: const Text('Autoplay aktivieren'),
              subtitle: const Text('Bei aktivem Autoplay wechseln die Übungen automatisch nach der Pause.'),
              secondary: const Tooltip(
                message: 'Autoplay kann im Training jederzeit pausiert oder deaktiviert werden.',
                child: Icon(Icons.info_outline),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _autoplay ? 1 : 0.4,
              child: IgnorePointer(
                ignoring: !_autoplay,
                child: Wrap(
                  spacing: 12,
                  children: [3, 4, 5]
                      .map((seconds) => ChoiceChip(
                            label: Text('${seconds}s'),
                            selected: _delay == seconds,
                            onSelected: (_) => setState(() => _delay = seconds),
                          ))
                      .toList(),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Weiter zum Training'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => Navigator.of(context).pop(
                  MoroPreCheckResult(
                    autoplayEnabled: _autoplay,
                    autoplayDelaySeconds: _delay,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
