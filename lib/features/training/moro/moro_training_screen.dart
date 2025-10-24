import 'package:flutter/material.dart';

import 'moro_exercise_screen.dart';
import 'moro_models.dart';
import 'moro_repository.dart';
import 'moro_speed_store.dart';

class MoroTrainingScreen extends StatefulWidget {
  const MoroTrainingScreen({super.key});
  @override
  State<MoroTrainingScreen> createState() => _MoroTrainingScreenState();
}

class _MoroTrainingScreenState extends State<MoroTrainingScreen> {
  late Future<List<MoroExercise>> _future;
  final Map<int, int> _offsets = {}; // exerciseIndex -> offset (0..3)

  @override
  void initState() {
    super.initState();
    _future = MoroRepository().load();
  }

  Future<int> _getOffset(int idx) async {
    if (_offsets.containsKey(idx)) return _offsets[idx]!;
    final v = await MoroSpeedStore.getOffsetForExercise(idx);
    _offsets[idx] = v;
    return v;
  }

  Future<void> _setOffset(int idx, int v) async {
    await MoroSpeedStore.setOffsetForExercise(idx, v);
    setState(() => _offsets[idx] = v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moro Training')),
      body: FutureBuilder<List<MoroExercise>>(
        future: _future,
        builder: (c, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Fehler beim Laden: ${snap.error}'));
          }
          final items = snap.data ?? const <MoroExercise>[];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: items.map((ex) {
              return FutureBuilder<int>(
                future: _getOffset(ex.index),
                builder: (context, ofsSnap) {
                  final offs = ofsSnap.data ?? 0;
                  final subtitle = ex.type == MoroExerciseType.phased4x
                      ? '3 Wdh · 4 Phasen × ${(ex.baseSeconds + offs)}s · Pause 3s'
                      : '6 Wdh · ${(ex.baseSeconds + offs)}s je Wdh · Pause 3s';

                  return Card(
                    child: ListTile(
                      title: Text('${ex.index}. ${ex.title}'),
                      subtitle: Text(subtitle),
                      leading: _SpeedChips(
                        value: offs,
                        onChanged: (v) => _setOffset(ex.index, v),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _openExercise(context, ex, offs),
                        child: const Text('Start'),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Future<void> _openExercise(
    BuildContext context,
    MoroExercise ex,
    int offset,
  ) async {
    await Navigator.of(context).pushNamed(
      '/training/moro/${ex.index}',
      arguments: MoroExerciseScreenArgs(
        exercise: ex,
        offset: offset,
      ),
    );
  }
}

class _SpeedChips extends StatelessWidget {
  final int value; // 0..3
  final ValueChanged<int> onChanged;
  const _SpeedChips({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const opts = [0, 1, 2, 3];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value == 0 ? 'Standard' : '+${value}s',
          style: const TextStyle(fontSize: 12),
        ),
        Wrap(
          spacing: 6,
          children: opts.map((v) {
            return ChoiceChip(
              label: Text(v == 0 ? 'Std' : '+${v}s'),
              selected: v == value,
              onSelected: (_) => onChanged(v),
            );
          }).toList(),
        ),
      ],
    );
  }
}
