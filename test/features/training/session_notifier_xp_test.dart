import 'package:flutter_test/flutter_test.dart';
import 'package:free_base/features/training/models/exercise_item.dart';
import 'package:free_base/features/training/models/session_state.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/features/training/services/exercise_repository.dart';
import 'package:free_base/features/training/services/session_repository.dart';
import 'package:free_base/features/training/services/sync_service.dart';

class _TestSessionRepository extends SessionRepository {
  SessionState? saved;

  @override
  Future<SessionState?> load() async => saved;

  @override
  Future<void> save(SessionState state) async {
    saved = state;
  }

  @override
  Future<void> clear() async {
    saved = null;
  }
}

class _TestSyncService implements SyncService {
  @override
  Future<void> dispose() async {}

  @override
  Future<void> enqueue(SessionState state) async {}

  @override
  Stream<SyncStatusEvent> get statusStream => Stream<SyncStatusEvent>.empty();
}

class _TestExerciseRepository extends ExerciseRepository {
  _TestExerciseRepository(this.items);

  final List<ExerciseItem> items;

  @override
  List<ExerciseItem> getExercisesForPhase(String phaseId) => items;
}

SessionNotifier _createNotifier({DateTime? plannedFor}) {
  final exercises = List.generate(7, (i) {
    final index = i + 1;
    return ExerciseItem(
      id: '0-$index',
      name: 'Übung $index',
      imagePath: 'placeholder',
      activeSeconds: 8,
      restSeconds: 4,
      repetitions: 1,
    );
  });
  final exerciseRepo = _TestExerciseRepository(exercises);
  final sessionRepository = _TestSessionRepository();
  final notifier = SessionNotifier(
    sessionRepository,
    _TestSyncService(),
    exerciseRepo,
    exercises,
    SessionState(
      phaseId: '0',
      exerciseIndex: 0,
      completedReps: 0,
      remainingSeconds: exercises.first.activeSeconds,
      isPaused: true,
      startedAt: plannedFor ?? DateTime(2024, 1, 1),
      plannedFor: plannedFor ?? DateTime(2024, 1, 1),
      status: SessionStatus.planned,
    ),
  );
  return notifier;
}

void main() {
  group('SessionNotifier gamification', () {
    test('computeXp returns combined xp for exercises', () {
      final notifier = _createNotifier();
      expect(notifier.computeXp(), 30 * 5 + 60 * 2);
    });

    test('applyCompletionRewards increases xp and streak', () {
      final notifier = _createNotifier();
      final yesterday = DateTime(2024, 1, 1);
      notifier.state = notifier.state.copyWith(
        xpTotal: 90,
        dailyXp: 0,
        streakCount: 1,
        lastCompletedOn: yesterday,
      );

      final completion = DateTime(2024, 1, 2, 8);
      notifier.applyCompletionRewards(completionDate: completion);

      expect(notifier.state.xpTotal, 90 + notifier.computeXp());
      expect(notifier.state.dailyXp, notifier.computeXp());
      expect(notifier.state.streakCount, 2);
      expect(notifier.state.streakFrozenUntil, isNotNull);
    });

    test('refreshScheduleStatus resets daily xp and clears expired freeze', () {
      final notifier = _createNotifier(plannedFor: DateTime.now().add(const Duration(days: 1)));
      final last = DateTime.now().subtract(const Duration(days: 2));
      notifier.state = notifier.state.copyWith(
        dailyXp: 120,
        lastCompletedOn: DateTime(last.year, last.month, last.day),
        streakFrozenUntil: DateTime.now().subtract(const Duration(days: 1)),
        streakCount: 3,
        status: SessionStatus.planned,
        plannedFor: DateTime.now().add(const Duration(days: 1)),
      );

      notifier.refreshScheduleStatus();

      expect(notifier.state.dailyXp, 0);
      expect(notifier.state.streakFrozenUntil, isNull);
    });
  });
}
