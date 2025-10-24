import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:free_base/constants/app_strings.dart';
import 'package:free_base/firebase_options.dart';
import 'package:free_base/features/onboarding/services/auth_service.dart';
import 'package:free_base/features/onboarding/services/secure_storage_service.dart';
import 'package:free_base/features/onboarding/state/auth_provider.dart';
import 'package:free_base/features/common/error_screen.dart';

import 'package:free_base/features/training/models/session_state.dart';
import 'package:free_base/features/training/models/session_state_adapter.dart';
import 'package:free_base/features/training/services/session_repository.dart';
import 'package:free_base/features/training/services/sync_service.dart';
import 'package:free_base/features/training/services/exercise_repository.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/features/training/widgets/session_sync_listener.dart';

import 'package:free_base/features/calendar/models/calendar_event.dart';
import 'package:free_base/features/calendar/models/calendar_event_adapter.dart';
import 'package:free_base/features/calendar/services/calendar_service.dart';
import 'package:free_base/features/calendar/services/golden_day_service.dart';
import 'package:free_base/features/questionnaire/questionnaire_screen.dart';
import 'package:free_base/services/app_intent_handler.dart';
import 'package:free_base/services/app_route_guard.dart';
import 'package:free_base/services/app_router.dart';
import 'package:free_base/services/feature_flags.dart';

const FeatureFlags _localFeatureFlags = FeatureFlags(
  parentsTrackEnabled: true,
  trainerTrackEnabled: true,
  forumEnabled: false,
  achievementsEnabled: false,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialisiere Firebase NUR, wenn es noch nicht existiert (hilft beim Hot Restart im Debugging)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e, st) {
    // Optional: Duplicate-app explizit abfangen (nur im Debug sinnvoll)
    if (e is FirebaseException && e.code == 'duplicate-app') {
      debugPrint('Firebase wurde bereits initialisiert (duplicate-app).');
      // -> ignorieren, App läuft weiter
    } else {
      debugPrint('Error initializing Firebase: $e');
      debugPrintStack(stackTrace: st);
      runApp(
        const MaterialApp(
          home: ErrorScreen(
            message:
                'Firebase konnte nicht initialisiert werden. Bitte Einstellungen prüfen.',
          ),
        ),
      );
      return;
    }
  }

  // Hive-Init und lokale Datenbank
  await Hive.initFlutter();
  final storage = SecureStorageService();
  final encryptionKey = await storage.getEncryptionKey();

  Hive.registerAdapter(SessionStatusAdapter());
  Hive.registerAdapter(SessionStateAdapter());
  await Hive.openBox<SessionState>('session_state',
      encryptionCipher: HiveAesCipher(encryptionKey));

  await Hive.openBox('questionnaire_progress',
      encryptionCipher: HiveAesCipher(encryptionKey));

  Hive.registerAdapter(CalendarEventAdapter());
  await Hive.openBox<CalendarEvent>('calendar_events',
      encryptionCipher: HiveAesCipher(encryptionKey));

  final sessionRepository = SessionRepository();
  final savedSession = await sessionRepository.load();
  final plannedFor = DateTime.now().add(const Duration(days: 1));
  final initialSessionState = savedSession ??
      SessionState(
        phaseId: '0',
        exerciseIndex: 0,
        completedReps: 0,
        remainingSeconds: 8,
        isPaused: true,
        startedAt: plannedFor,
        plannedFor: plannedFor,
        status: SessionStatus.planned,
      );

  runApp(
    MyApp(
      sessionRepository: sessionRepository,
      initialSessionState: initialSessionState,
    ),
  );
}

class MyApp extends StatefulWidget {
  final SessionRepository sessionRepository;
  final SessionState initialSessionState;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  MyApp({
    super.key,
    required this.sessionRepository,
    required this.initialSessionState,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouteGuard _routeGuard = AppRouteGuard();
  GoRouter? _router;
  AppIntentHandler? _intentHandler;
  bool _intentInitialized = false;

  @override
  void dispose() {
    _intentHandler?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FeatureFlags>.value(
          value: _localFeatureFlags,
        ),
        ChangeNotifierProvider<AppAuthProvider>(
          create: (_) => AppAuthProvider(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<SessionRepository>.value(
          value: widget.sessionRepository,
        ),
        Provider<SyncService>(
          create: (_) => SyncService(
            widget.sessionRepository,
            FirebaseFirestore.instance,
            FirebaseAuth.instance.currentUser?.uid ?? '',
          ),
          dispose: (_, svc) => svc.dispose(),
        ),
        Provider<CalendarService>(
          create: (_) => CalendarService(),
        ),
        Provider<GoldenDayService>(
          create: (_) => GoldenDayService(),
        ),
        Provider<ExerciseRepository>(
          create: (_) => ExerciseRepository(),
        ),
        ChangeNotifierProvider<SessionNotifier>(
          create: (ctx) {
            final exRepo = ctx.read<ExerciseRepository>();
            final initialExercises =
                exRepo.getExercisesForPhase(widget.initialSessionState.phaseId);
            return SessionNotifier(
              widget.sessionRepository,
              ctx.read<SyncService>(),
              ctx.read<CalendarService>(),
              ctx.read<GoldenDayService>(),
              exRepo,
              initialExercises,
              widget.initialSessionState,
            );
          },
        ),
        createQuestionnaireProvider(),
      ],
      child: Builder(
        builder: (context) {
          final authProvider = context.watch<AppAuthProvider>();
          _router ??= AppRouter(
            refreshListenable: authProvider,
            guard: _routeGuard,
          ).router;

          if (!_intentInitialized) {
            _intentInitialized = true;
            authProvider.addListener(_routeGuard.reset);
            _intentHandler = AppIntentHandler(
              FirebaseDynamicLinks.instance,
              _router!,
            )..initialize();
          }

          return MaterialApp.router(
            title: AppStrings.appName,
            theme: ThemeData(primarySwatch: Colors.blue),
            scaffoldMessengerKey: widget.scaffoldMessengerKey,
            routerConfig: _router!,
            builder: (context, child) => SessionSyncListener(
              messengerKey: widget.scaffoldMessengerKey,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
