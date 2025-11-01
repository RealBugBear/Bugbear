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

class _ChecklistItem {
  const _ChecklistItem(this.label, {this.tooltip});

  final String label;
  final String? tooltip;
}

class _MoroPreCheckScreenState extends State<MoroPreCheckScreen> {
  static const _checklistItems = [
    _ChecklistItem('Ich bin nüchtern oder habe höchstens einen leichten Snack gegessen.'),
    _ChecklistItem('Ich trage lockere Kleidung und habe ausreichend Platz für das Training.'),
    _ChecklistItem('Ich habe Wasser bereitgestellt.'),
    _ChecklistItem(
      'Optional: Ich habe eine binaurale Musikspur vorbereitet (empfohlen).',
      tooltip: 'Binaurale Musik kann die Konzentration unterstützen, ist aber nicht verpflichtend.',
    ),
    _ChecklistItem(
      'Optional: Ich habe meine eigene Musik oder Playlist vorbereitet.',
      tooltip: 'Falls gewünscht, kannst du mit deiner eigenen Musik trainieren.',
    ),
    _ChecklistItem(
      'Optional: Ich kenne den Autoplay-Modus – die Übungen wechseln automatisch nach der Pause.',
      tooltip: 'Der Autoplay-Modus kann jederzeit während des Trainings angepasst werden.',
    ),
  ];

  late final List<bool> _checkItems;
  bool _autoplay = true;
  int _delay = 3;

  @override
  void initState() {
    super.initState();
    _checkItems = List<bool>.filled(_checklistItems.length, false);
  }

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
            ..._checklistItems.asMap().entries.map((entry) {
              return CheckboxListTile(
                value: _checkItems[entry.key],
                onChanged: (v) => setState(() => _checkItems[entry.key] = v ?? false),
                title: Text(entry.value.label),
                secondary: entry.value.tooltip == null
                    ? null
                    : Tooltip(
                        message: entry.value.tooltip!,
                        child: const Icon(Icons.info_outline),
                      ),
              );
            }),
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
              child: ElevatedButton(
                onPressed: _checkItems.every((v) => v)
                    ? () => Navigator.of(context).pop(
                          MoroPreCheckResult(
                            autoplayEnabled: _autoplay,
                            autoplayDelaySeconds: _delay,
                          ),
                        )
                    : null,
                child: const Text('Weiter zum Training'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
