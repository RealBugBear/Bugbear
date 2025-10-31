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
  final Map<int, bool> _checkItems = {
    0: false,
    1: false,
    2: false,
    3: false,
  };
  bool _autoplay = true;
  int _delay = 3;

  static const _items = [
    'Nüchtern oder mit leichtem Snack',
    'Lockere Kleidung und ausreichend Platz',
    'Wasser bereitgestellt',
    'Optional: Musik oder binaurale Spur vorbereitet',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pre-Check Moro Training')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kurze Vorbereitung',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._items.asMap().entries.map((entry) {
              return CheckboxListTile(
                value: _checkItems[entry.key],
                onChanged: (v) => setState(() => _checkItems[entry.key] = v ?? false),
                title: Text(entry.value),
              );
            }),
            const Divider(height: 32),
            SwitchListTile.adaptive(
              value: _autoplay,
              onChanged: (v) => setState(() => _autoplay = v),
              title: const Text('Autoplay aktivieren'),
              subtitle: const Text('Übungen wechseln automatisch nach der Pause'),
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
                onPressed: _checkItems.values.every((v) => v)
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
