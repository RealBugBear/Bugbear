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

import 'package:bugbear_app/features/training/models/session_state.dart';
import 'package:bugbear_app/features/training/models/session_state_adapter.dart';
import 'package:bugbear_app/features/training/services/session_repository.dart';
import 'package:bugbear_app/features/training/services/sync_service.dart';
import 'package:bugbear_app/features/training/services/exercise_repository.dart';
import 'package:bugbear_app/features/training/notifier/session_notifier.dart';

import 'package:bugbear_app/features/calendar/models/calendar_event.dart';
import 'package:bugbear_app/features/calendar/models/calendar_event_adapter.dart';
import 'package:bugbear_app/features/calendar/services/calendar_service.dart';

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

  // CalendarEvent persistence
  Hive.registerAdapter(CalendarEventAdapter());
  await Hive.openBox<CalendarEvent>('calendar_events');

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
        },
      ),
    );
  }
}
