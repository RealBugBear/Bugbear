import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final int level;
  final double levelProgress;
  final int xpTotal;
  final int xpToNextLevel;
  final int streakCount;
  final bool freezeAvailable;
  final int dailyXp;
  final DateTime? freezeUntil;

  const DashboardHeader({
    super.key,
    required this.level,
    required this.levelProgress,
    required this.xpTotal,
    required this.xpToNextLevel,
    required this.streakCount,
    required this.freezeAvailable,
    required this.dailyXp,
    this.freezeUntil,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge;
    final secondaryStyle = theme.textTheme.bodyMedium;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Level $level', style: titleStyle),
                      const SizedBox(height: 4),
                      Text(
                        '$xpTotal XP gesamt',
                        style: secondaryStyle,
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text('Streak $streakCount'),
                  avatar: const Icon(Icons.local_fire_department_outlined),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: levelProgress.clamp(0, 1),
            ),
            const SizedBox(height: 8),
            Text(
              '$xpToNextLevel XP bis zum nächsten Level',
              style: secondaryStyle,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text('Daily XP: $dailyXp'),
                  avatar: const Icon(Icons.flash_on_outlined),
                ),
                if (freezeAvailable)
                  Chip(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    avatar: const Icon(Icons.ac_unit),
                    label: Text(
                      freezeUntil != null
                          ? 'Freeze bis ${_formatDate(freezeUntil!)}'
                          : 'Freeze aktiv',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return '${normalized.day}.${normalized.month}.${normalized.year}';
  }
}
