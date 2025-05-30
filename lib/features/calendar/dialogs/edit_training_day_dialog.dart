// lib/features/calendar/dialogs/edit_training_day_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/calendar_event.dart';
import '../notifier/calendar_notifier.dart';
import '../services/calendar_service.dart';

/// EditTrainingDayDialog
///
/// Modaler Dialog zur Bearbeitung eines einzelnen Trainingstags:
/// - Phase per Dropdown
/// - Golden Day per Switch
/// - Abgeschlossen per Switch
/// - Notiz per TextFormField (max. 500 Zeichen)
/// Auf „Speichern“ wird CalendarService.saveTrainingDay() aufgerufen
/// und der CalendarNotifier lädt den aktuellen Monat neu.
class EditTrainingDayDialog extends StatefulWidget {
  final CalendarEvent event;
  const EditTrainingDayDialog({Key? key, required this.event})
      : super(key: key);

  @override
  State<EditTrainingDayDialog> createState() =>
      _EditTrainingDayDialogState();
}

class _EditTrainingDayDialogState
    extends State<EditTrainingDayDialog> {
  final _formKey = GlobalKey<FormState>();
  static const _maxNotes = 500;

  late String _phase;
  late bool _isGolden;
  late bool _isCompleted;
  late String _notes;

  final List<String> _phases = ['0','1','2a','2b','3','4','5','6','7','8','9'];

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _phase = e.title.replaceFirst('Phase ', '');
    _isGolden = e.isGoldenDay;
    _isCompleted = e.isCompleted;
    _notes = e.notes;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text('Bearbeite Trainingstag ${_formatDate(widget.event.date)}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _phase,
                decoration: const InputDecoration(labelText: 'Phase'),
                items: _phases
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text('Phase $p'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _phase = v!),
              ),
              SwitchListTile(
                title: const Text('Golden Day'),
                value: _isGolden,
                onChanged: (v) => setState(() => _isGolden = v),
              ),
              SwitchListTile(
                title: const Text('Abgeschlossen'),
                value: _isCompleted,
                onChanged: (v) => setState(() => _isCompleted = v),
              ),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(
                  labelText: 'Notiz',
                  hintText: 'Maximal 500 Zeichen',
                ),
                maxLength: _maxNotes,
                maxLines: null,
                onSaved: (v) => _notes = v ?? '',
                validator: (v) {
                  if ((v ?? '').length > _maxNotes) {
                    return 'Maximal $_maxNotes Zeichen';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              final updated = widget.event.copyWith(
                title: 'Phase $_phase',
                isGoldenDay: _isGolden,
                isCompleted: _isCompleted,
                notes: _notes,
              );

              await context
                  .read<CalendarService>()
                  .saveTrainingDay(updated);
              await context
                  .read<CalendarNotifier>()
                  .loadMonth(context.read<CalendarNotifier>().focusedDay);

              Navigator.of(context).pop(updated);
            }
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')}.${d.month.toString().padLeft(2,'0')}.${d.year}';
}
