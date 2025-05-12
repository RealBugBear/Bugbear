import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:bugbear_app/models/calendar_model.dart';
import 'package:bugbear_app/models/training_data.dart';
import 'package:bugbear_app/services/training_service.dart';
import 'package:bugbear_app/services/local_storage_service.dart';
import 'package:bugbear_app/core/themes/app_theme.dart';
import 'package:bugbear_app/core/widgets/confirm_dialog.dart';
import 'package:bugbear_app/widgets/app_drawer.dart';
import 'package:bugbear_app/generated/l10n.dart';

/// Displays the user's calendar of completed sessions.
///
/// Uses a [LocalStorageService] from the widget tree unless overridden for testing.
class ProfileScreen extends StatelessWidget {
  final TrainingService trainingService;
  final LocalStorageService? localStorage;
  final FirebaseAuth auth;

  ProfileScreen({
    Key? key,
    TrainingService? trainingService,
    this.localStorage,
    FirebaseAuth? auth,
  })  : trainingService = trainingService ?? TrainingService(),
        auth = auth ?? FirebaseAuth.instance,
        super(key: key);

  User? get currentUser => auth.currentUser;

  @override
  Widget build(BuildContext context) {
    // Choose the initialized storage, falling back to Provider if not provided.
    final storage =
        localStorage ?? Provider.of<LocalStorageService>(context, listen: false);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text(S.of(context).profileTitle)),
        drawer: const AppDrawer(),
        body: Center(child: Text(S.of(context).userNotLoggedIn)),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => CalendarModel(
        trainingService: trainingService,
        localStorage: storage,
      ),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CalendarModel>();

    // Find index of active program; default to 0 if not found to avoid RangeError.
    int programIndex =
        allPrograms.indexWhere((p) => p.id == model.activeProgramId);
    if (programIndex < 0 || programIndex >= programColors.length) {
      programIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).overallProgressTitle)),
      drawer: const AppDrawer(),
      body: TableCalendar(
        firstDay: DateTime.utc(2000),
        lastDay: DateTime.utc(2100),
        focusedDay: model.visibleMonth,
        calendarFormat: CalendarFormat.month,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarStyle: CalendarStyle(
          markerDecoration: BoxDecoration(
            color: programColors[programIndex],
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            border: Border.all(color: AppColors.gold, width: 2),
            shape: BoxShape.circle,
          ),
        ),
        selectedDayPredicate: (date) => model.completedDates
            .contains(DateTime(date.year, date.month, date.day)),
        onDaySelected: (selectedDay, focusedDay) async {
          // grab locale before any await:
          final locale = Localizations.localeOf(context).toString();
          final formatted =
              DateFormat.yMMMd(locale).format(selectedDay);

          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => ConfirmDialog(
              title: 'Eintragen?',
              message:
                  'Möchtest Du das Tracking für $formatted speichern?',
              confirmLabel: S.of(context).yes,
              cancelLabel: S.of(context).no,
            ),
          );

          if (confirmed == true) {
            await model.toggleCompleted(selectedDay);
          }
        },
        onPageChanged: (focused) => model.setVisibleMonth = focused,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: S.of(context).selectPhase,
        child: const Icon(Icons.edit),
        onPressed: () => _showPhaseSelection(context),
      ),
    );
  }

  void _showPhaseSelection(BuildContext context) {
    final model = context.read<CalendarModel>();

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return ListView(
          children: allPrograms.map((prog) {
            final idx = allPrograms.indexOf(prog);
            final progress =
                (model.completedDates.length / prog.plannedSessions)
                    .clamp(0.0, 1.0);

            // Capture the NavigatorState *before* the async gap:
            final navigator = Navigator.of(sheetContext);

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: programColors[idx],
                child: Text('${(progress * 100).toInt()}%'),
              ),
              title: Text(prog.name),
              onTap: () async {
                await model.setActiveProgram(prog.id);
                navigator.pop();
              },
            );
          }).toList(),
        );
      },
    );
  }
}
