import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:free_base/constants/app_strings.dart';
import 'package:free_base/firebase_options.dart';
import 'package:free_base/features/onboarding/services/auth_service.dart';
import 'package:free_base/features/onboarding/services/secure_storage_service.dart';
import 'package:free_base/features/onboarding/state/auth_provider.dart';
import 'package:free_base/features/common/splash_screen.dart';
import 'package:free_base/features/common/route_guard.dart';
import 'package:free_base/features/onboarding/screens/login_screen.dart';
import 'package:free_base/features/onboarding/screens/register_screen.dart';
import 'package:free_base/features/onboarding/screens/role_selection_screen.dart';
import 'package:free_base/features/common/dashboard_screen.dart';
import 'package:free_base/features/onboarding/profile/settings_screen.dart';
import 'package:free_base/features/training/moro/moro_exercise_screen.dart';
import 'package:free_base/features/training/moro/moro_training_screen.dart';
import 'package:free_base/features/training/training_completed_screen.dart';
import 'package:free_base/features/training/training_screen.dart';
import 'package:free_base/features/calendar/screens/calendar_screen.dart';
import 'package:free_base/features/common/error_screen.dart';

import 'package:free_base/features/training/models/session_state.dart';
import 'package:free_base/features/training/models/session_state_adapter.dart';
import 'package:free_base/features/training/services/session_repository.dart';
import 'package:free_base/features/training/services/sync_service.dart';
import 'package:free_base/features/training/services/exercise_repository.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';

import 'package:free_base/features/calendar/models/calendar_event.dart';
import 'package:free_base/features/calendar/models/calendar_event_adapter.dart';
import 'package:free_base/features/calendar/services/calendar_service.dart';
import 'package:free_base/features/calendar/services/golden_day_service.dart';
import 'package:free_base/features/questionnaire/questionnaire_screen.dart';
import 'package:free_base/features/questionnaire/quiz_intro_screen.dart';
import 'package:free_base/features/profile/screens/profile_overview_screen.dart';
import 'package:free_base/features/profile/screens/reflex_profile_detail_screen.dart';
import 'package:free_base/features/profile/models/reflex_profile.dart';
import 'package:free_base/features/common/feature_placeholder_screen.dart';
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
                exRepo.getExercisesForPhase(initialSessionState.phaseId);
            return SessionNotifier(
              sessionRepository,
              ctx.read<SyncService>(),
              ctx.read<CalendarService>(),
              ctx.read<GoldenDayService>(),
              exRepo,
              initialExercises,
              initialSessionState,
            );
          },
        ),
        createQuestionnaireProvider(),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final routeName = settings.name ?? '';

          if (routeName.startsWith('/training/moro/')) {
            final args = settings.arguments;
            if (args is MoroExerciseScreenArgs) {
              return guard(
                settings,
                (_) => MoroExerciseScreen(
                  exercise: args.exercise,
                  offset: args.offset,
                ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => const ErrorScreen(
                message: 'Ungültige Trainingsparameter.',
              ),
              settings: settings,
            );
          }

          switch (routeName) {
            case '/':
              return MaterialPageRoute(
                builder: (_) => const SplashScreen(),
                settings: settings,
              );
            case '/login':
              return MaterialPageRoute(
                builder: (_) => const LoginScreen(),
                settings: settings,
              );
            case '/register':
              return MaterialPageRoute(
                builder: (_) => const RegisterScreen(),
                settings: settings,
              );
            case '/select-role':
              return MaterialPageRoute(
                builder: (_) => const RoleSelectionScreen(),
                settings: settings,
              );
            case '/dashboard':
              return guard(settings, (_) => const DashboardScreen());
            case '/settings':
              return guard(settings, (_) => const SettingsScreen());
            case '/training':
              return guard(settings, (_) => const TrainingScreen());
            case '/training/moro':
              return guard(settings, (_) => const MoroTrainingScreen());
            case '/training/completed':
              return guard(settings, (_) => const TrainingCompletedScreen());
            case '/calendar':
              return guard(settings, (_) => const CalendarScreen());
            case '/questionnaire':
              return guard(settings, (_) => const QuizIntroScreen());
            case '/questionnaire/questions':
              return guard(settings, (_) => const QuestionnaireScreen());
            case '/reflexe-profil':
              return guard(settings, (_) => const ProfileOverviewScreen());
            case '/reflexe-profil/detail':
              return guard(settings, (_) {
                final profile = settings.arguments as ReflexProfile;
                return ReflexProfileDetailScreen(profile: profile);
              });
            case '/forum':
              final flags = Provider.of<FeatureFlags>(context, listen: false);
              if (!flags.forumEnabled) {
                return MaterialPageRoute(
                  builder: (_) => const ErrorScreen(
                    message: 'Dieses Feature ist aktuell deaktiviert.',
                  ),
                  settings: settings,
                );
              }
              return guard(
                settings,
                (_) => const FeaturePlaceholderScreen(
                  title: 'Forum',
                  message:
                      'Hier entsteht das Community-Forum. Die Inhalte folgen in einer späteren Version.',
                ),
              );
            case '/achievements':
              final flags = Provider.of<FeatureFlags>(context, listen: false);
              if (!flags.achievementsEnabled) {
                return MaterialPageRoute(
                  builder: (_) => const ErrorScreen(
                    message: 'Dieses Feature ist aktuell deaktiviert.',
                  ),
                  settings: settings,
                );
              }
              return guard(
                settings,
                (_) => const FeaturePlaceholderScreen(
                  title: 'Erfolge',
                  message:
                      'Deine Erfolge erscheinen hier, sobald das Feature freigeschaltet ist.',
                ),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => const ErrorScreen(
                  message: 'Die angeforderte Seite wurde nicht gefunden.',
                ),
                settings: settings,
              );
          }
        },
      ),
    );
  }
}
