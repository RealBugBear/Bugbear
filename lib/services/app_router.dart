import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/calendar/screens/calendar_screen.dart';
import 'package:free_base/features/common/dashboard_route_args.dart';
import 'package:free_base/features/common/dashboard_screen.dart';
import 'package:free_base/features/common/error_screen.dart';
import 'package:free_base/features/common/feature_placeholder_screen.dart';
import 'package:free_base/features/common/splash_screen.dart';
import 'package:free_base/features/onboarding/profile/settings_screen.dart';
import 'package:free_base/features/onboarding/screens/login_screen.dart';
import 'package:free_base/features/onboarding/screens/register_screen.dart';
import 'package:free_base/features/onboarding/screens/role_selection_screen.dart';
import 'package:free_base/features/profile/models/reflex_profile.dart';
import 'package:free_base/features/profile/screens/profile_overview_screen.dart';
import 'package:free_base/features/profile/screens/reflex_profile_detail_screen.dart';
import 'package:free_base/features/questionnaire/questionnaire_result_screen.dart';
import 'package:free_base/features/questionnaire/questionnaire_screen.dart';
import 'package:free_base/features/questionnaire/quiz_intro_screen.dart';
import 'package:free_base/features/training/moro/moro_exercise_screen.dart';
import 'package:free_base/features/training/moro/moro_training_screen.dart';
import 'package:free_base/features/training/training_completed_screen.dart';
import 'package:free_base/features/training/training_screen.dart';
import 'package:free_base/services/app_route_guard.dart';
import 'package:free_base/services/training_intent.dart';
import 'package:free_base/services/app_shell.dart';
import 'package:free_base/services/app_routes.dart';
import 'package:free_base/services/feature_flags.dart';

class AppRouter {
  AppRouter({
    required Listenable refreshListenable,
    required AppRouteGuard guard,
  })  : _guard = guard,
        router = GoRouter(
          navigatorKey: _rootNavigatorKey,
          initialLocation: AppRoutePaths.splash,
          refreshListenable: refreshListenable,
          redirect: guard.redirect,
          routes: _buildRoutes(),
        );

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _calendarNavigatorKey = GlobalKey<NavigatorState>();
  static final _dashboardNavigatorKey = GlobalKey<NavigatorState>();
  static final _trainingNavigatorKey = GlobalKey<NavigatorState>();
  static final _profileNavigatorKey = GlobalKey<NavigatorState>();

  final AppRouteGuard _guard;
  final GoRouter router;

  static List<RouteBase> _buildRoutes() {
    return [
      GoRoute(
        path: AppRoutePaths.splash,
        name: AppRouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.login,
        name: AppRouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.register,
        name: AppRouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.roleSelection,
        name: AppRouteNames.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.settings,
        name: AppRouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.questionnaireIntro,
        name: AppRouteNames.questionnaireIntro,
        builder: (context, state) => const QuizIntroScreen(),
        routes: [
          GoRoute(
            path: 'questions',
            name: AppRouteNames.questionnaire,
            builder: (context, state) => const QuestionnaireScreen(),
            routes: [
              GoRoute(
                path: 'result',
                name: AppRouteNames.questionnaireResult,
                builder: (context, state) => const QuestionnaireResultScreen(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            navigatorKey: _calendarNavigatorKey,
            initialLocation: AppRoutePaths.calendar,
            routes: [
              GoRoute(
                path: AppRoutePaths.calendar,
                name: AppRouteNames.calendar,
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            initialLocation: AppRoutePaths.dashboard,
            routes: [
              GoRoute(
                path: AppRoutePaths.dashboard,
                name: AppRouteNames.dashboard,
                builder: (context, state) {
                  DashboardRouteArgs? args;
                  final extra = state.extra;
                  if (extra is DashboardRouteArgs) {
                    args = extra;
                  } else if (state.uri.queryParameters.containsKey('startTraining')) {
                    final startTraining =
                        state.uri.queryParameters['startTraining'] == 'true';
                    args = DashboardRouteArgs(startTraining: startTraining);
                  }
                  return DashboardScreen(routeArgs: args);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _trainingNavigatorKey,
            initialLocation: AppRoutePaths.training,
            routes: [
              GoRoute(
                path: AppRoutePaths.training,
                name: AppRouteNames.training,
                builder: (context, state) {
                  final extra = state.extra;
                  TrainingIntent? intent;
                  if (extra is TrainingIntent) {
                    intent = extra;
                  } else {
                    final start = state.uri.queryParameters['start'];
                    final resumeId = state.uri.queryParameters['sessionId'];
                    if (start == 'true') {
                      intent = TrainingIntent.start();
                    } else if (resumeId != null && resumeId.isNotEmpty) {
                      intent = TrainingIntent.resume(resumeId);
                    }
                  }
                  return TrainingScreen(intent: intent);
                },
                routes: [
                  GoRoute(
                    path: 'completed',
                    name: AppRouteNames.trainingCompleted,
                    builder: (context, state) => const TrainingCompletedScreen(),
                  ),
                  GoRoute(
                    path: 'moro',
                    name: AppRouteNames.moroTraining,
                    builder: (context, state) => const MoroTrainingScreen(),
                    routes: [
                      GoRoute(
                        path: ':exerciseId',
                        name: AppRouteNames.moroExercise,
                        builder: (context, state) {
                          final args = state.extra;
                          if (args is MoroExerciseScreenArgs) {
                            return MoroExerciseScreen(
                              exercise: args.exercise,
                              offset: args.offset,
                            );
                          }
                          return const ErrorScreen(
                            message: 'Ungültige Trainingsparameter.',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            initialLocation: AppRoutePaths.profile,
            routes: [
              GoRoute(
                path: AppRoutePaths.profile,
                name: AppRouteNames.profile,
                builder: (context, state) => const ProfileOverviewScreen(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    name: AppRouteNames.profileDetail,
                    builder: (context, state) {
                      final profile = state.extra;
                      if (profile is ReflexProfile) {
                        return ReflexProfileDetailScreen(profile: profile);
                      }
                      return const ErrorScreen(
                        message: 'Das Profil konnte nicht geladen werden.',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutePaths.forum,
        name: AppRouteNames.forum,
        builder: (context, state) {
          final flags = Provider.of<FeatureFlags>(context, listen: false);
          if (!flags.forumEnabled) {
            return const ErrorScreen(
              message: 'Dieses Feature ist aktuell deaktiviert.',
            );
          }
          return const FeaturePlaceholderScreen(
            title: 'Forum',
            message:
                'Hier entsteht das Community-Forum. Die Inhalte folgen in einer späteren Version.',
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.achievements,
        name: AppRouteNames.achievements,
        builder: (context, state) {
          final flags = Provider.of<FeatureFlags>(context, listen: false);
          if (!flags.achievementsEnabled) {
            return const ErrorScreen(
              message: 'Dieses Feature ist aktuell deaktiviert.',
            );
          }
          return const FeaturePlaceholderScreen(
            title: 'Erfolge',
            message:
                'Deine Erfolge erscheinen hier, sobald das Feature freigeschaltet ist.',
          );
        },
      ),
    ];
  }
}
