import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/calendar_service.dart';

/// GoldenDayBanner
///
/// Displays the upcoming Golden Day using a paw icon and the
/// date retrieved from [CalendarService].
class GoldenDayBanner extends StatelessWidget {
  const GoldenDayBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final calendar = context.read<CalendarService>();
    return FutureBuilder<DateTime?>(
      future: calendar.loadUpcomingGoldenDay(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final day = snapshot.data;
        final text = day == null
            ? 'Kein Golden Day geplant'
            : DateFormat('dd.MM.yyyy').format(day);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/paw.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(text),
          ],
        );
      },
    );
  }
}
