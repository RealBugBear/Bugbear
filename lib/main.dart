import 'dart:async';

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
import 'package:free_base/features/onboarding/state/consent_notifier.dart';
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
import 'package:free_base/features/calendar/notifier/calendar_notifier.dart';
import 'package:free_base/features/calendar/services/calendar_service.dart';
import 'package:free_base/features/calendar/services/golden_day_service.dart';
import 'package:free_base/features/common/state/dashboard_view_model.dart';
import 'package:free_base/features/questionnaire/questionnaire_screen.dart';
import 'package:free_base/features/profile/state/profile_shop_notifier.dart';
import 'package:free_base/services/app_intent_handler.dart';
import 'package:free_base/services/app_route_guard.dart';
import 'package:free_base/services/app_router.dart';
import 'package:free_base/services/feature_flags.dart';
import 'package:free_base/services/telemetry/telemetry_service.dart';

import 'package:free_base/features/onboarding/models/consent_state.dart';
import 'package:free_base/features/gamification/models/gamification_state.dart';
import 'package:free_base/services/reminder/reminder_service.dart';

const FeatureFlags _localFeatureFlags = FeatureFlags(
  parentsTrackEnabled: true,
  trainerTrackEnabled: true,
  forumEnabled: false,
  achievementsEnabled: false,
  consentRequired: true,
  remindersEnabled: false,
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
  Hive.registerAdapter(ConsentStateAdapter());
  Hive.registerAdapter(GamificationStateAdapter());
  await Hive.openBox<SessionState>('session_state',
      encryptionCipher: HiveAesCipher(encryptionKey));

  final consentBox = await Hive.openBox<ConsentState>('user_settings',
      encryptionCipher: HiveAesCipher(encryptionKey));

  await Hive.openBox('questionnaire_progress',
      encryptionCipher: HiveAesCipher(encryptionKey));

  Hive.registerAdapter(CalendarEventAdapter());
  await Hive.openBox<CalendarEvent>('calendar_events',
      encryptionCipher: HiveAesCipher(encryptionKey));

  await Hive.openBox<GamificationState>('gamification_state',
      encryptionCipher: HiveAesCipher(encryptionKey));

  final cosmeticsBox = await Hive.openBox('cosmetics_catalog',
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
      consentBox: consentBox,
      cosmeticsBox: cosmeticsBox,
    ),
  );
}

class MyApp extends StatefulWidget {
  final SessionRepository sessionRepository;
  final SessionState initialSessionState;
  final Box<ConsentState> consentBox;
  final Box cosmeticsBox;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  MyApp({
    super.key,
    required this.sessionRepository,
    required this.initialSessionState,
    required this.consentBox,
    required this.cosmeticsBox,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TelemetryService _telemetry = DebugTelemetryService();
  late final ConsentNotifier _consentNotifier;
  late final AppRouteGuard _routeGuard;
  GoRouter? _router;
  AppIntentHandler? _intentHandler;
  bool _intentInitialized = false;

  @override
  void initState() {
    super.initState();
    final localeTag =
        WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag();
    _consentNotifier = ConsentNotifier(
      widget.consentBox,
      defaultLocale: localeTag,
    );
    _routeGuard = AppRouteGuard(
      consentNotifier: _consentNotifier,
      loadSessionState: widget.sessionRepository.load,
      consentRequired: _localFeatureFlags.consentRequired,
    );
    unawaited(
      _telemetry.logEvent(
        'app_open',
        properties: {
          'locale': localeTag,
          'feature_flag_snapshot': _localFeatureFlags.toMap().toString(),
          'connectivity_status': 'unknown',
        },
      ),
    );
  }

  @override
  void dispose() {
    _intentHandler?.dispose();
    _consentNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FeatureFlags>.value(
          value: _localFeatureFlags,
        ),
        Provider<TelemetryService>.value(
          value: _telemetry,
        ),
        ChangeNotifierProvider<AppAuthProvider>(
          create: (_) => AppAuthProvider(),
        ),
        ChangeNotifierProvider<ConsentNotifier>.value(
          value: _consentNotifier,
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
        ChangeNotifierProvider<ReminderService>(
          create: (_) {
            final service = ReminderService();
            unawaited(service.initialize());
            return service;
          },
        ),
        ChangeNotifierProvider<SessionNotifier>(
          create: (ctx) {
            final exRepo = ctx.read<ExerciseRepository>();
            final initialExercises =
                exRepo.getExercisesForPhase(widget.initialSessionState.phaseId);
            return SessionNotifier(
              widget.sessionRepository,
              ctx.read<SyncService>(),
              exRepo,
              initialExercises,
              widget.initialSessionState,
            );
          },
        ),
        ChangeNotifierProvider<CalendarNotifier>(
          create: (ctx) {
            final notifier = CalendarNotifier(ctx.read<CalendarService>());
            notifier.loadMonth(DateTime.now());
            return notifier;
          },
        ),
        ChangeNotifierProvider<ProfileShopNotifier>(
          create: (ctx) => ProfileShopNotifier(
            firestore: FirebaseFirestore.instance,
            sessionNotifier: ctx.read<SessionNotifier>(),
            cacheBox: widget.cosmeticsBox,
          ),
        ),
        ChangeNotifierProxyProvider3<SessionNotifier, CalendarNotifier,
            ReminderService, DashboardViewModel>(
          create: (ctx) => DashboardViewModel(
            ctx.read<SessionNotifier>(),
            ctx.read<CalendarNotifier>(),
            ctx.read<ReminderService>(),
          ),
          update: (ctx, session, calendar, reminder, previous) {
            final model = previous ??
                DashboardViewModel(session, calendar, reminder);
            model.updateSources(session, calendar, reminder);
            return model;
          },
        ),
        createQuestionnaireProvider(),
      ],
      child: Builder(
        builder: (context) {
          final authProvider = context.watch<AppAuthProvider>();
          final consentNotifier = context.watch<ConsentNotifier>();
          final sessionNotifier = context.watch<SessionNotifier>();
          final refreshListenable =
              Listenable.merge([authProvider, consentNotifier, sessionNotifier]);
          _router ??= AppRouter(
            refreshListenable: refreshListenable,
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
