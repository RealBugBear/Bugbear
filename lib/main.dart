// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:bugbear_app/firebase_options.dart';
import 'package:bugbear_app/features/onboarding/services/auth_service.dart';
import 'package:bugbear_app/features/onboarding/state/auth_provider.dart';
import 'package:bugbear_app/features/common/splash_screen.dart';
import 'package:bugbear_app/features/onboarding/screens/login_screen.dart';
import 'package:bugbear_app/features/onboarding/screens/register_screen.dart';
import 'package:bugbear_app/features/onboarding/screens/role_selection_screen.dart';
import 'package:bugbear_app/features/common/dashboard_screen.dart';
import 'package:bugbear_app/features/onboarding/profile/settings_screen.dart';
import 'package:bugbear_app/features/training/training_screen.dart';
import 'package:bugbear_app/features/calendar/screens/calendar_screen.dart';
import 'package:bugbear_app/features/questionnaire/screens/language_selection_screen.dart';
import 'package:bugbear_app/features/questionnaire/screens/questionnaire_screen.dart';
import 'package:bugbear_app/features/questionnaire/screens/result_screen.dart';

import 'package:bugbear_app/features/training/models/session_state.dart';
import 'package:bugbear_app/features/training/models/session_state_adapter.dart';
import 'package:bugbear_app/features/training/services/session_repository.dart';
import 'package:bugbear_app/features/training/services/sync_service.dart';
import 'package:bugbear_app/features/training/services/exercise_repository.dart';
import 'package:bugbear_app/features/training/notifier/session_notifier.dart';
import 'package:bugbear_app/features/questionnaire/services/questionnaire_repository.dart';
import 'package:bugbear_app/features/questionnaire/notifier/questionnaire_notifier.dart';
import 'package:bugbear_app/features/questionnaire/models/questionnaire_progress.dart';
import 'package:bugbear_app/features/questionnaire/screens/questionnaire_language_screen.dart';
import 'package:bugbear_app/features/questionnaire/screens/questionnaire_screen.dart';
import 'package:bugbear_app/features/questionnaire/screens/reflexe_profil_temp.dart';

import 'package:bugbear_app/features/calendar/models/calendar_event.dart';
import 'package:bugbear_app/features/calendar/models/calendar_event_adapter.dart';
import 'package:bugbear_app/features/calendar/services/calendar_service.dart';

import 'package:bugbear_app/features/reflexe/services/reflex_profile_service.dart';
import 'package:bugbear_app/features/reflexe/screens/reflexe_profil.dart';
import 'package:bugbear_app/features/reflexe/screens/reflexe_profil_temp.dart';

import 'package:bugbear_app/features/questionnaire/models/questionnaire_state.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  // SessionState persistence
  Hive.registerAdapter(SessionStatusAdapter());
  Hive.registerAdapter(SessionStateAdapter());
  await Hive.openBox<SessionState>('session_state');

  // Questionnaire persistence
  Hive.registerAdapter(AnswerTypeAdapter());
  Hive.registerAdapter(QuestionnaireLanguageAdapter());
  Hive.registerAdapter(QuestionnaireStateAdapter());
  await Hive.openBox<QuestionnaireState>('questionnaire_state');

  // CalendarEvent persistence
  Hive.registerAdapter(CalendarEventAdapter());
  await Hive.openBox<CalendarEvent>('calendar_events');

  // Questionnaire persistence
  await Hive.openBox('questionnaire_state');

  final questionnaireRepository = QuestionnaireRepository();
  final savedProgress = await questionnaireRepository.loadProgress();
  final initialProgress = savedProgress ??
      QuestionnaireProgress(language: 'de', index: 0, answers: {});


  final sessionRepository = SessionRepository();
  final saved = await sessionRepository.load();
  final initialState = saved ??
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
      initialSessionState: initialState,
      questionnaireRepository: questionnaireRepository,
      initialProgress: initialProgress,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SessionRepository sessionRepository;
  final SessionState initialSessionState;
  final QuestionnaireRepository questionnaireRepository;
  final QuestionnaireProgress initialProgress;

  const MyApp({
    super.key,
    required this.sessionRepository,
    required this.initialSessionState,
    required this.questionnaireRepository,
    required this.initialProgress,
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
        Provider<ReflexProfileService>(
          create: (_) => ReflexProfileService(),
        ),
        Provider<ExerciseRepository>(
          create: (_) => ExerciseRepository(),
        ),
        Provider<QuestionnaireRepository>.value(
          value: questionnaireRepository,
        ),
        ChangeNotifierProvider<QuestionnaireNotifier>(
          create: (_) => QuestionnaireNotifier(
            questionnaireRepository,
            initialProgress,
          )..loadQuestions(),
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
          '/reflex-profil': (c) => const ReflexeProfilScreen(),
          '/questionnaire-language': (c) => const QuestionnaireLanguageScreen(),
          '/questionnaire': (c) => const QuestionnaireScreen(),
          '/reflexe_profil_temp': (c) => const ReflexeProfilTemp(),
          '/select-language': (c) => const LanguageSelectionScreen(),
          '/questionnaire': (c) => const QuestionnaireScreen(),
          '/result': (c) => const ResultScreen(),

        },
      ),
    );
  }
}
