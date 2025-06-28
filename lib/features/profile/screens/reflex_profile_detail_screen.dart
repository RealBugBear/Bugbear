import 'package:flutter/material.dart';
import '../models/reflex_profile.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../calendar/widgets/golden_day_banner.dart';

class ReflexProfileDetailScreen extends StatelessWidget {
  final ReflexProfile profile;
  const ReflexProfileDetailScreen({super.key, required this.profile});

  Color _colorForPercent(double p) {
    if (p >= 0.75) return Colors.green;
    if (p >= 0.5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(profile.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Reflexe',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...profile.reflexScores.entries.map((e) {
            final yes = e.value['yes'] as int? ?? 0;
            final total = e.value['total'] as int? ?? 0;
            final ratio = total == 0 ? 0.0 : yes / total;
            final percent = (ratio * 100).round();
            return ListTile(
              title: Text(e.key),
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
          }),
          const SizedBox(height: 24),
          const GoldenDayBanner(),
          const SizedBox(height: 24),
          const Text(
            'Antworten',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...profile.answers.entries.map((e) => ListTile(
                title: Text('Frage ${e.key}'),
                trailing: Text(e.value),
              )),
        ],
      ),
    );
  }
}
