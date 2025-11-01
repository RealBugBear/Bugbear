import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/training/models/exercise_item.dart';
import 'package:free_base/features/training/models/session_state.dart';
import 'package:free_base/features/training/moro/moro_exercise_screen.dart';
import 'package:free_base/features/training/moro/media_player_service.dart';
import 'package:free_base/features/training/moro/moro_models.dart';
import 'package:free_base/features/training/moro/moro_repository.dart';
import 'package:free_base/features/training/moro/moro_training_screen.dart';
import 'package:free_base/features/training/moro/pre_check_screen.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/features/training/services/exercise_repository.dart';
import 'package:free_base/features/training/services/session_repository.dart';
import 'package:free_base/features/training/services/sync_service.dart';
import 'package:free_base/services/app_router.dart';
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

class _TestExerciseRepository extends ExerciseRepository {
  final List<ExerciseItem> _items;

  _TestExerciseRepository(this._items);

  @override
  List<ExerciseItem> getExercisesForPhase(String phaseId) => _items;
}

class _FakeMoroRepository extends MoroRepository {
  final List<MoroExercise> _items;

  _FakeMoroRepository(this._items);

  @override
  Future<List<MoroExercise>> load() async => _items;
}

List<MoroExercise> _buildFakeExercises(int count) {
  return List.generate(count, (index) {
    final idx = index + 1;
    return MoroExercise(
      index: idx,
      title: 'Übung $idx',
      type: MoroExerciseType.simple,
      repeats: 1,
      phasesPerRepeat: 1,
      baseSeconds: 5,
      autoplayDefault: 3,
      goal: 'Ziel $idx',
      startPosition: 'Start',
      steps: const [],
      cues: const [],
      breath: const MoroBreathPattern(pattern: 'breath'),
      abortRules: const [],
      notes: null,
      tags: const [],
      version: '1.0.0',
      media: const MoroMedia(),
      resumeKey: 'moro_$idx',
      mediaFallbackImage: null,
      xpReward: 10,
    );
  });
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

class _FallbackStubExerciseScreen extends StatefulWidget {
  const _FallbackStubExerciseScreen({
    required this.args,
    required this.visited,
    this.popResult,
  });

  final MoroExerciseScreenArgs args;
  final List<int> visited;
  final MoroExerciseResult? popResult;

  @override
  State<_FallbackStubExerciseScreen> createState() =>
      _FallbackStubExerciseScreenState();
}

class _FallbackStubExerciseScreenState
    extends State<_FallbackStubExerciseScreen> {
  @override
  void initState() {
    super.initState();
    widget.visited.add(widget.args.exercise.index);
    final result = widget.popResult;
    if (result != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pop(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('fallback-${widget.args.exercise.index}'),
      ),
    );
  }
}

class _FakeMediaPlayerService extends MoroMediaPlayerService {
  @override
  Future<MoroMediaLoadResult> loadForExercise(MoroExercise exercise) async {
    return const MoroMediaLoadResult();
  }
}

GoRouter _createRouter(
  ValueNotifier<int> counter, {
  bool useFallback = false,
  MoroRepository? repository,
  Widget Function(MoroExerciseScreenArgs args)? fallbackBuilder,
}) {
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
                  if (useFallback) {
                    final exerciseId = int.tryParse(id) ?? 0;
                    return MoroExerciseRouteLoader(
                      exerciseId: exerciseId,
                      repository: repository,
                      screenBuilder: fallbackBuilder,
                    );
                  }
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
    if (Hive.isBoxOpen('moro_speed_offsets')) {
      await Hive.box('moro_speed_offsets').close();
    }
    try {
      await Hive.deleteBoxFromDisk('moro_speed_offsets');
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

  testWidgets('fallback opens exercise when args missing on start', (tester) async {
    final notifier = _createNotifier();
    final counter = ValueNotifier<int>(0);
    final visited = <int>[];
    final repo = _FakeMoroRepository(_buildFakeExercises(3));
    final router = _createRouter(
      counter,
      useFallback: true,
      repository: repo,
      fallbackBuilder: (args) => _FallbackStubExerciseScreen(
        args: args,
        visited: visited,
      ),
    );

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
    expect(visited, equals([1]));
    expect(find.text('fallback-1'), findsOneWidget);
  });

  testWidgets('fallback resume opens stored exercise without args', (tester) async {
    final notifier = _createNotifier();
    notifier.saveResumePoint('moro_2', const {
      'stage': 'active',
      'repeatIdx': 1,
      'phaseIdx': 1,
      'remainingMs': 5000,
    });
    final counter = ValueNotifier<int>(0);
    final visited = <int>[];
    final repo = _FakeMoroRepository(_buildFakeExercises(3));
    final router = _createRouter(
      counter,
      useFallback: true,
      repository: repo,
      fallbackBuilder: (args) => _FallbackStubExerciseScreen(
        args: args,
        visited: visited,
      ),
    );

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
    expect(visited, equals([2]));
    expect(find.text('fallback-2'), findsOneWidget);
  });

  testWidgets('autoplay opens next exercise intro stage', (tester) async {
    final notifier = _createNotifier();
    final counter = ValueNotifier<int>(0);
    final visited = <int>[];
    final builtScreens = <int>[];
    final repo = _FakeMoroRepository(_buildFakeExercises(3));
    final router = _createRouter(
      counter,
      useFallback: true,
      repository: repo,
      fallbackBuilder: (args) {
        builtScreens.add(args.exercise.index);
        if (args.exercise.index == 1) {
          return _FallbackStubExerciseScreen(
            args: args,
            visited: visited,
            popResult: MoroExerciseResult(
              completed: true,
              autoplayEnabled: true,
              autoplayDelaySeconds: args.autoplayDelaySeconds,
              exerciseIndex: args.exercise.index,
              hasNextExercise: true,
            ),
          );
        }
        return MoroExerciseScreen(
          exercise: args.exercise,
          offset: args.offset,
          autoplay: args.autoplay,
          autoplayDelaySeconds: args.autoplayDelaySeconds,
          totalExercises: args.totalExercises,
          mediaService: _FakeMediaPlayerService(),
        );
      },
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<SessionNotifier>.value(
        value: notifier,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.goNamed(AppRouteNames.training, extra: TrainingIntent.start());

    await tester.pump();
    await tester.pumpAndSettle();

    expect(visited, equals([1]));
    expect(builtScreens, equals([1, 2]));
    expect(find.text('Vorbereitung'), findsOneWidget);
  });

  testWidgets('fallback handles autoplay navigation without args', (tester) async {
    final notifier = _createNotifier();
    final counter = ValueNotifier<int>(0);
    final visited = <int>[];
    final repo = _FakeMoroRepository(_buildFakeExercises(3));
    final router = _createRouter(
      counter,
      useFallback: true,
      repository: repo,
      fallbackBuilder: (args) {
        final shouldAutoplay = args.exercise.index == 1;
        return _FallbackStubExerciseScreen(
          args: args,
          visited: visited,
          popResult: shouldAutoplay
              ? MoroExerciseResult(
                  completed: true,
                  autoplayEnabled: true,
                  autoplayDelaySeconds: args.autoplayDelaySeconds,
                  exerciseIndex: args.exercise.index,
                  hasNextExercise: true,
                )
              : null,
        );
      },
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<SessionNotifier>.value(
        value: notifier,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.goNamed(AppRouteNames.training, extra: TrainingIntent.start());

    await tester.pump();
    await tester.pumpAndSettle();

    // allow autoplay result to propagate and open next exercise
    await tester.pump();
    await tester.pumpAndSettle();

    expect(counter.value, greaterThanOrEqualTo(1));
    expect(visited, equals([1, 2]));
    expect(find.text('fallback-2'), findsOneWidget);
  });
}
