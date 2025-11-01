import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/common/dashboard_route_args.dart';
import 'package:free_base/features/common/dashboard_screen.dart';
import 'package:free_base/features/common/error_screen.dart';
import 'package:free_base/features/common/feature_placeholder_screen.dart';
import 'package:free_base/features/common/splash_screen.dart';
import 'package:free_base/features/onboarding/profile/settings_screen.dart';
import 'package:free_base/features/onboarding/screens/consent_screen.dart';
import 'package:free_base/features/onboarding/screens/login_screen.dart';
import 'package:free_base/features/onboarding/screens/register_screen.dart';
import 'package:free_base/features/onboarding/screens/role_selection_screen.dart';
import 'package:free_base/features/profile/models/reflex_profile.dart';
import 'package:free_base/features/profile/screens/profile_overview_screen.dart';
import 'package:free_base/features/profile/screens/reflex_profile_detail_screen.dart';
import 'package:free_base/features/profile/screens/shop_screen.dart';
import 'package:free_base/features/questionnaire/questionnaire_result_screen.dart';
import 'package:free_base/features/questionnaire/questionnaire_screen.dart';
import 'package:free_base/features/questionnaire/quiz_intro_screen.dart';
import 'package:free_base/features/training/moro/moro_exercise_screen.dart';
import 'package:free_base/features/training/moro/moro_models.dart';
import 'package:free_base/features/training/moro/moro_repository.dart';
import 'package:free_base/features/training/moro/moro_speed_store.dart';
import 'package:free_base/features/training/moro/pre_check_screen.dart';
import 'package:free_base/features/training/moro/moro_training_screen.dart';
import 'package:free_base/features/training/training_completed_screen.dart';
import 'package:free_base/services/app_route_guard.dart';
import 'package:free_base/services/app_shell.dart';
import 'package:free_base/services/app_routes.dart';
import 'package:free_base/services/feature_flags.dart';
import 'package:free_base/services/training_intent.dart';

class AppRouter {
  AppRouter({
    required Listenable refreshListenable,
    required AppRouteGuard guard,
  })  : router = GoRouter(
          navigatorKey: _rootNavigatorKey,
          initialLocation: AppRoutePaths.splash,
          refreshListenable: refreshListenable,
          redirect: guard.redirect,
          routes: _buildRoutes(),
        );

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _dashboardNavigatorKey = GlobalKey<NavigatorState>();
  static final _profileNavigatorKey = GlobalKey<NavigatorState>();

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
        path: AppRoutePaths.consent,
        name: AppRouteNames.consent,
        builder: (context, state) => const ConsentScreen(),
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
                  GoRoute(
                    path: 'shop',
                    name: AppRouteNames.profileShop,
                    builder: (context, state) {
                      final profile = state.extra;
                      if (profile is ReflexProfile) {
                        return ShopScreen(profile: profile);
                      }
                      return const ErrorScreen(
                        message: 'Der Shop konnte nicht geöffnet werden.',
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
        path: AppRoutePaths.training,
        name: AppRouteNames.training,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra;
          return MoroTrainingScreen(
            intent: extra is TrainingIntent ? extra : null,
          );
        },
        routes: [
          GoRoute(
            path: 'completed',
            name: AppRouteNames.trainingCompleted,
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const TrainingCompletedScreen(),
          ),
          GoRoute(
            path: 'moro/precheck',
            name: AppRouteNames.moroPrecheck,
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const MoroPreCheckScreen(),
          ),
          GoRoute(
            path: 'moro/:exerciseId',
            name: AppRouteNames.moroExercise,
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final args = state.extra;
              if (args is MoroExerciseScreenArgs) {
                return MoroExerciseScreen(
                  exercise: args.exercise,
                  offset: args.offset,
                  autoplay: args.autoplay,
                  autoplayDelaySeconds: args.autoplayDelaySeconds,
                  totalExercises: args.totalExercises,
                );
              }
              final idParam = state.pathParameters['exerciseId'];
              final exerciseId = int.tryParse(idParam ?? '');
              if (exerciseId == null) {
                developer.log(
                  'Failed to parse exerciseId "$idParam" for MoroExercise route without extra.',
                  name: 'AppRouter',
                );
                return const ErrorScreen(
                  message: 'Ungültige Trainingsparameter.',
                );
              }
              developer.log(
                'Missing MoroExerciseScreenArgs for exercise $exerciseId – loading fallback.',
                name: 'AppRouter',
              );
              return MoroExerciseRouteLoader(
                exerciseId: exerciseId,
              );
            },
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

class MoroExerciseRouteLoader extends StatelessWidget {
  final int exerciseId;
  final MoroRepository? repository;
  final Widget Function(MoroExerciseScreenArgs args)? screenBuilder;

  const MoroExerciseRouteLoader({
    super.key,
    required this.exerciseId,
    this.repository,
    this.screenBuilder,
  });

  Future<MoroExerciseScreenArgs> _loadArgs() async {
    final repo = repository ?? MoroRepository();
    final exercises = await repo.load();
    MoroExercise? exercise;
    for (final ex in exercises) {
      if (ex.index == exerciseId) {
        exercise = ex;
        break;
      }
    }
    if (exercise == null) {
      throw StateError('Moro exercise $exerciseId nicht gefunden.');
    }
    final offset = await MoroSpeedStore.getOffsetForExercise(exercise.index);
    return MoroExerciseScreenArgs(
      exercise: exercise,
      offset: offset,
      autoplay: true,
      autoplayDelaySeconds: exercise.autoplayDefault,
      totalExercises: exercises.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MoroExerciseScreenArgs>(
      future: _loadArgs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.hasError) {
          developer.log(
            'Fallback für Moro-Training fehlgeschlagen: ${snapshot.error}',
            name: 'AppRouter',
          );
          return const ErrorScreen(
            message: 'Das Training konnte nicht geladen werden.',
          );
        }
        final args = snapshot.data!;
        final builder = screenBuilder;
        if (builder != null) {
          return builder(args);
        }
        return MoroExerciseScreen(
          exercise: args.exercise,
          offset: args.offset,
          autoplay: args.autoplay,
          autoplayDelaySeconds: args.autoplayDelaySeconds,
          totalExercises: args.totalExercises,
        );
      },
    );
  }
}
