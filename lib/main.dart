import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:bugbear_app/firebase_options.dart';
import 'package:bugbear_app/features/onboarding/services/auth_service.dart';
import 'package:bugbear_app/features/onboarding/services/secure_storage_service.dart';
import 'package:bugbear_app/features/onboarding/state/auth_provider.dart';
import 'package:bugbear_app/features/common/splash_screen.dart';
import 'package:bugbear_app/features/onboarding/screens/login_screen.dart';
import 'package:bugbear_app/features/onboarding/screens/register_screen.dart';
import 'package:bugbear_app/features/onboarding/screens/role_selection_screen.dart';
import 'package:bugbear_app/features/common/dashboard_screen.dart';
import 'package:bugbear_app/features/onboarding/profile/settings_screen.dart';
import 'package:bugbear_app/features/training/training_screen.dart';
import 'package:bugbear_app/features/calendar/screens/calendar_screen.dart';
import 'package:bugbear_app/features/common/error_screen.dart';

import 'package:bugbear_app/features/training/models/session_state.dart';
import 'package:bugbear_app/features/training/models/session_state_adapter.dart';
import 'package:bugbear_app/features/training/services/session_repository.dart';
import 'package:bugbear_app/features/training/services/sync_service.dart';
import 'package:bugbear_app/features/training/services/exercise_repository.dart';
import 'package:bugbear_app/features/training/notifier/session_notifier.dart';

import 'package:bugbear_app/features/calendar/models/calendar_event.dart';
import 'package:bugbear_app/features/calendar/models/calendar_event_adapter.dart';
import 'package:bugbear_app/features/calendar/services/calendar_service.dart';
import 'package:bugbear_app/features/questionnaire/questionnaire_screen.dart';
import 'package:bugbear_app/features/questionnaire/quiz_intro_screen.dart';
import 'package:bugbear_app/features/profile/screens/profile_overview_screen.dart';
import 'package:bugbear_app/features/profile/screens/reflex_profile_detail_screen.dart';
import 'package:bugbear_app/features/profile/models/reflex_profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // **DEBUG PRINT** zu Beginn – überprüfe, ob Key gesetzt ist:
  const androidApiKey = String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
  debugPrint('DEBUG: FIREBASE_ANDROID_API_KEY="$androidApiKey"');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
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
  final initialSessionState = savedSession ??
      SessionState(
        phaseId: '0',
        exerciseIndex: 0,
        completedReps: 0,
        remainingSeconds: 8,
        isPaused: false,
        startedAt: DateTime.now(),
      );

  runApp(
    MyApp(
      sessionRepository: sessionRepository,
      initialSessionState: initialSessionState,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SessionRepository sessionRepository;
  final SessionState initialSessionState;

  const MyApp({
    super.key,
    required this.sessionRepository,
    required this.initialSessionState,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppAuthProvider>(
          create: (_) => AppAuthProvider(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<SessionRepository>.value(
          value: sessionRepository,
        ),
        Provider<SyncService>(
          create: (_) => SyncService(
            sessionRepository,
            FirebaseFirestore.instance,
            FirebaseAuth.instance.currentUser?.uid ?? '',
          ),
          dispose: (_, svc) => svc.dispose(),
        ),
        Provider<CalendarService>(
          create: (_) => CalendarService(),
        ),
        Provider<ExerciseRepository>(
          create: (_) => ExerciseRepository(),
        ),
        ChangeNotifierProvider<SessionNotifier>(
          create: (ctx) {
            final exRepo = ctx.read<ExerciseRepository>();
            final initialExercises =
                exRepo.getExercisesForPhase(initialSessionState.phaseId);
            return SessionNotifier(
              sessionRepository,
              ctx.read<SyncService>(),
              ctx.read<CalendarService>(),
              exRepo,
              initialExercises,
              initialSessionState,
            );
          },
        ),
        createQuestionnaireProvider(),
      ],
      child: MaterialApp(
        title: 'BugBear App',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (c) => const SplashScreen(),
          '/login': (c) => const LoginScreen(),
          '/register': (c) => const RegisterScreen(),
          '/select-role': (c) => const RoleSelectionScreen(),
          '/dashboard': (c) => const DashboardScreen(),
          '/settings': (c) => const SettingsScreen(),
          '/training': (c) => const TrainingScreen(),
          '/calendar': (c) => const CalendarScreen(),
          '/questionnaire': (c) => const QuizIntroScreen(),
          '/questionnaire/questions': (c) => const QuestionnaireScreen(),
          '/reflexe-profil': (c) => const ProfileOverviewScreen(),
          '/reflexe-profil/detail': (c) {
            final profile = ModalRoute.of(c)!.settings.arguments as ReflexProfile;
            return ReflexProfileDetailScreen(profile: profile);
          },
        },
      ),
    );
  }
}
