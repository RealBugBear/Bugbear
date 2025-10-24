import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:go_router/go_router.dart';

import 'package:free_base/services/app_routes.dart';
import 'package:free_base/services/training_intent.dart';

enum AppIntentType { trainingStart, sessionResume, questionnaire }

class AppIntentHandler {
  AppIntentHandler(
    this._dynamicLinks,
    this._router,
  );

  final FirebaseDynamicLinks _dynamicLinks;
  final GoRouter _router;
  StreamSubscription<PendingDynamicLinkData>? _subscription;

  static const trainingStartPath = '/training/start';
  static const sessionResumePrefix = '/training/session';
  static const questionnairePath = '/questionnaire/start';

  Future<void> initialize() async {
    final initialLink = await _dynamicLinks.getInitialLink();
    if (initialLink != null) {
      await _handleUri(initialLink.link);
    }

    _subscription = _dynamicLinks.onLink.listen((event) {
      final uri = event.link;
      unawaited(_handleUri(uri));
    });
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }

  Future<void> handleUri(Uri uri) => _handleUri(uri);

  Future<void> _handleUri(Uri uri) async {
    final intent = _parseIntent(uri);
    if (intent == null) {
      return;
    }

    switch (intent.type) {
      case AppIntentType.trainingStart:
        _router.goNamed(
          AppRouteNames.training,
          extra: TrainingIntent.start(),
        );
        break;
      case AppIntentType.sessionResume:
        final sessionId = intent.sessionId;
        if (sessionId != null) {
          _router.goNamed(
            AppRouteNames.training,
            extra: TrainingIntent.resume(sessionId),
          );
        }
        break;
      case AppIntentType.questionnaire:
        _router.goNamed(AppRouteNames.questionnaireIntro);
        break;
    }
  }

  _AppIntent? _parseIntent(Uri uri) {
    final normalized = uri.path.toLowerCase();
    if (normalized == trainingStartPath) {
      return const _AppIntent(AppIntentType.trainingStart, null);
    }
    if (normalized.startsWith(sessionResumePrefix)) {
      final segments = uri.pathSegments;
      if (segments.length >= 4 && segments[2].isNotEmpty) {
        final sessionId = segments[2];
        final action = segments.last.toLowerCase();
        if (action == 'resume') {
          return _AppIntent(AppIntentType.sessionResume, sessionId);
        }
      }
    }
    if (normalized == questionnairePath) {
      return const _AppIntent(AppIntentType.questionnaire, null);
    }
    return null;
  }

  Uri buildTrainingStartLink(Uri baseUri) {
    return baseUri.replace(path: trainingStartPath);
  }

  Uri buildSessionResumeLink(Uri baseUri, String sessionId) {
    final path = '$sessionResumePrefix/$sessionId/resume';
    return baseUri.replace(path: path);
  }

  Uri buildQuestionnaireLink(Uri baseUri) {
    return baseUri.replace(path: questionnairePath);
  }
}

class _AppIntent {
  final AppIntentType type;
  final String? sessionId;

  const _AppIntent(this.type, this.sessionId);
}
