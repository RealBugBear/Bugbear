import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/reflex_profile.dart';
import '../mappers/reflex_score_mapper.dart';

class ReflexProfileDetailScreen extends StatelessWidget {
  final ReflexProfile profile;
  const ReflexProfileDetailScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final scores =
        ReflexScoreMapper.fromStoredScores(profile.reflexScores);
    return Scaffold(
      appBar: AppBar(title: Text(profile.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visualisierung',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ReflexRadarChartPlaceholder(scores: scores),
                  const SizedBox(height: 12),
                  ReflexBarChartPlaceholder(scores: scores),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Reflexe',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...scores.map((vm) {
            final ratio = vm.ratio;
            final percent = vm.percentage;
            return ListTile(
              title: Text(vm.reflexName),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: LinearProgressIndicator(
                  value: ratio,
                  color: colorForRatio(ratio),
                  backgroundColor: Colors.grey.shade300,
                ),
              ),
              trailing: Text('$percent%'),
            );
          }),
          const SizedBox(height: 24),
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

class ReflexRadarChartPlaceholder extends StatelessWidget {
  const ReflexRadarChartPlaceholder({super.key, required this.scores});

  final List<ReflexScoreViewModel> scores;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _RadarPainter(scores),
        child: const Center(child: Text('Radar-Vorschau')), // placeholder label
      ),
    );
  }
}

class ReflexBarChartPlaceholder extends StatelessWidget {
  const ReflexBarChartPlaceholder({super.key, required this.scores});

  final List<ReflexScoreViewModel> scores;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: scores.map((vm) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  vm.reflexName,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: vm.ratio,
                    minHeight: 10,
                    color: colorForRatio(vm.ratio),
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text('${vm.percentage}%'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter(this.scores);

  final List<ReflexScoreViewModel> scores;

  @override
  void paint(Canvas canvas, Size size) {
    final count = scores.length;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2.2;
    final paintGrid = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke;
    final paintFill = Paint()
      ..color = Colors.blueAccent.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final paintStroke = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 1; i <= 3; i++) {
      final r = radius * (i / 3);
      canvas.drawCircle(center, r, paintGrid);
    }

    if (count == 0) {
      return;
    }

    final path = Path();
    for (var i = 0; i < count; i++) {
      final angle = (2 * math.pi * i / count) - math.pi / 2;
      final ratio = scores[i].ratio.clamp(0.0, 1.0);
      final point = Offset(
        center.dx + radius * ratio * math.cos(angle),
        center.dy + radius * ratio * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paintFill);
    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return !listEquals(oldDelegate.scores, scores);
  }
}

Color colorForRatio(double ratio) {
  if (ratio >= 0.75) return Colors.green;
  if (ratio >= 0.5) return Colors.orange;
  return Colors.red;
}
