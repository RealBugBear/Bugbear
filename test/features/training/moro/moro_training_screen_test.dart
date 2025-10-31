import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/calendar/models/calendar_event.dart';
import 'package:free_base/features/calendar/services/calendar_service.dart';
import 'package:free_base/features/calendar/services/golden_day_service.dart';
import 'package:free_base/features/training/models/exercise_item.dart';
import 'package:free_base/features/training/models/session_state.dart';
import 'package:free_base/features/training/moro/moro_training_screen.dart';
import 'package:free_base/features/training/moro/pre_check_screen.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/features/training/services/exercise_repository.dart';
import 'package:free_base/features/training/services/session_repository.dart';
import 'package:free_base/features/training/services/sync_service.dart';
import 'package:free_base/services/app_routes.dart';
import 'package:free_base/services/training_intent.dart';

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
  Stream<SyncStatusEvent> get statusStream => const Stream.empty();
}

class _TestCalendarService implements CalendarService {
  @override
  Future<void> addEvent(CalendarEvent event) async {}

  @override
  Future<void> removeEvent(String id) async {}

  @override
  Future<List<CalendarEvent>> loadEventsForMonth(DateTime month) async => const [];

  @override
  Future<void> saveTrainingDay(CalendarEvent event) async {}

  @override
  Future<DateTime?> loadUpcomingGoldenDay() async => null;
}

class _TestExerciseRepository extends ExerciseRepository {
  final List<ExerciseItem> _items;

  _TestExerciseRepository(this._items);

  @override
  List<ExerciseItem> getExercisesForPhase(String phaseId) => _items;
}

SessionNotifier _createNotifier() {
  final items = List.generate(3, (index) {
    final idx = index + 1;
    return ExerciseItem(
      id: 'moro-$idx',
      name: 'Übung $idx',
      imagePath: 'placeholder',
      activeSeconds: 8,
      restSeconds: 4,
      repetitions: 1,
    );
  });
  final repo = _TestSessionRepository();
  final notifier = SessionNotifier(
    repo,
    _TestSyncService(),
    _TestCalendarService(),
    GoldenDayService(),
    _TestExerciseRepository(items),
    items,
    SessionState(
      phaseId: '0',
      exerciseIndex: 0,
      completedReps: 0,
      remainingSeconds: items.first.activeSeconds,
      isPaused: true,
      startedAt: DateTime(2024, 1, 1),
      plannedFor: DateTime(2024, 1, 1),
      status: SessionStatus.planned,
      moroResume: const {},
    ),
  );
  return notifier;
}

class _AutoPopPrecheckScreen extends StatefulWidget {
  const _AutoPopPrecheckScreen({required this.counter});

  final ValueNotifier<int> counter;

  @override
  State<_AutoPopPrecheckScreen> createState() => _AutoPopPrecheckScreenState();
}

class _AutoPopPrecheckScreenState extends State<_AutoPopPrecheckScreen> {
  @override
  void initState() {
    super.initState();
    widget.counter.value++;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      GoRouter.of(context).pop(
        const MoroPreCheckResult(
          autoplayEnabled: true,
          autoplayDelaySeconds: 3,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('precheck')),
    );
  }
}

class _StubExerciseScreen extends StatelessWidget {
  const _StubExerciseScreen({required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('exercise-$exerciseId'),
      ),
    );
  }
}

GoRouter _createRouter(ValueNotifier<int> counter) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SizedBox.shrink(),
        routes: [
          GoRoute(
            path: 'training',
            name: AppRouteNames.training,
            builder: (context, state) => MoroTrainingScreen(
              intent: state.extra is TrainingIntent ? state.extra as TrainingIntent : null,
            ),
            routes: [
              GoRoute(
                path: 'moro/precheck',
                name: AppRouteNames.moroPrecheck,
                builder: (context, state) => _AutoPopPrecheckScreen(counter: counter),
              ),
              GoRoute(
                path: 'moro/:exerciseId',
                name: AppRouteNames.moroExercise,
                builder: (context, state) {
                  final id = state.pathParameters['exerciseId']!;
                  return _StubExerciseScreen(
                    exerciseId: id,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory hiveDir;

  setUpAll(() async {
    hiveDir = await Directory.systemTemp.createTemp('moro_training_test');
    Hive.init(hiveDir.path);
  });

  tearDown(() async {
    if (Hive.isBoxOpen('moro_progress')) {
      await Hive.box('moro_progress').close();
    }
    try {
      await Hive.deleteBoxFromDisk('moro_progress');
    } catch (_) {}
  });

  tearDownAll(() async {
    await Hive.close();
    if (hiveDir.existsSync()) {
      await hiveDir.delete(recursive: true);
    }
  });

  testWidgets('start intent triggers pre-check and opens first exercise', (tester) async {
    final notifier = _createNotifier();
    final counter = ValueNotifier<int>(0);
    final router = _createRouter(counter);

    await tester.pumpWidget(
      ChangeNotifierProvider<SessionNotifier>.value(
        value: notifier,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.goNamed(AppRouteNames.training, extra: TrainingIntent.start());

    await tester.pump();
    await tester.pumpAndSettle();

    expect(counter.value, greaterThanOrEqualTo(1));
    expect(find.text('exercise-1'), findsOneWidget);
  });

  testWidgets('resume intent opens stored exercise without pre-check', (tester) async {
    final notifier = _createNotifier();
    notifier.saveResumePoint('moro_2', const {
      'stage': 'active',
      'repeatIdx': 1,
      'phaseIdx': 1,
      'remainingMs': 5000,
    });
    final counter = ValueNotifier<int>(0);
    final router = _createRouter(counter);

    await tester.pumpWidget(
      ChangeNotifierProvider<SessionNotifier>.value(
        value: notifier,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.goNamed(AppRouteNames.training, extra: TrainingIntent.resume('moro_2'));

    await tester.pump();
    await tester.pumpAndSettle();

    expect(counter.value, 0);
    expect(find.text('exercise-2'), findsOneWidget);
  });
}
