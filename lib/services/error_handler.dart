import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Provides shared error handling utilities so that UI widgets can
/// consistently translate backend errors into user-friendly messages.
class ErrorHandler {
  const ErrorHandler._();

  /// Maps [error] to a localized human-readable message. German is used by
  /// default and can be toggled via [isGerman]. When no specific mapping is
  /// found, [fallback] (if provided) or a generic string is returned.
  static String messageFor(
    Object error, {
    bool isGerman = true,
    String? fallback,
  }) {
    if (error is FirebaseAuthException) {
      return _firebaseAuthMessage(error, isGerman, fallback);
    }

    if (error is FirebaseException) {
      return _firebaseMessage(error, isGerman, fallback);
    }

    if (error is PlatformException) {
      if (_isNetworkErrorCode(error.code)) {
        return _offlineMessage(isGerman);
      }
      return error.message ??
          fallback ??
          _defaultMessage(isGerman);
    }

    if (error is SocketException) {
      return _offlineMessage(isGerman);
    }

    if (error is TimeoutException) {
      return isGerman
          ? 'Die Anfrage hat zu lange gedauert. Bitte die Verbindung prüfen.'
          : 'The request timed out. Please check your connection.';
    }

    if (error is FormatException) {
      return isGerman
          ? 'Unerwartetes Datenformat. Bitte später erneut versuchen.'
          : 'Unexpected data format. Please try again later.';
    }

    return fallback ?? _defaultMessage(isGerman);
  }

  /// Shows a red floating [SnackBar] with [message] on the nearest
  /// [ScaffoldMessenger]. Existing snack bars are cleared first to avoid
  /// stacking duplicate errors.
  static void showErrorSnack(BuildContext context, String message) {
    if (message.isEmpty) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// Convenience helper: determines the locale from [context], derives the
  /// message for [error] and displays it via [showErrorSnack].
  static void showError(BuildContext context, Object error, {String? fallback}) {
    final locale = Localizations.maybeLocaleOf(context);
    final isGerman = locale?.languageCode.toLowerCase() == 'de';
    final message = messageFor(
      error,
      isGerman: isGerman,
      fallback: fallback,
    );
    showErrorSnack(context, message);
  }

  static String _firebaseAuthMessage(
    FirebaseAuthException exception,
    bool isGerman,
    String? fallback,
  ) {
    switch (exception.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-email':
        return isGerman
            ? 'E-Mail oder Passwort ist ungültig.'
            : 'Email or password is invalid.';
      case 'user-disabled':
        return isGerman
            ? 'Dieses Konto wurde deaktiviert.'
            : 'This account has been disabled.';
      case 'email-already-in-use':
        return isGerman
            ? 'Diese E-Mail-Adresse wird bereits verwendet.'
            : 'This email address is already in use.';
      case 'weak-password':
        return isGerman
            ? 'Das Passwort ist zu schwach.'
            : 'The password is too weak.';
      case 'too-many-requests':
        return isGerman
            ? 'Zu viele Anmeldeversuche. Bitte später erneut versuchen.'
            : 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return _offlineMessage(isGerman);
      case 'operation-not-allowed':
        return isGerman
            ? 'Diese Anmeldung ist deaktiviert. Bitte Support kontaktieren.'
            : 'This sign-in method is disabled. Please contact support.';
    }

    return fallback ?? _defaultMessage(isGerman);
  }

  static String _firebaseMessage(
    FirebaseException exception,
    bool isGerman,
    String? fallback,
  ) {
    switch (exception.code) {
      case 'permission-denied':
      case 'unauthenticated':
        return isGerman
            ? 'Zugriff verweigert. Bitte erneut anmelden.'
            : 'Permission denied. Please sign in again.';
      case 'unavailable':
      case 'network-request-failed':
      case 'network-error':
        return _offlineMessage(isGerman);
      case 'cancelled':
      case 'aborted':
        return isGerman
            ? 'Der Vorgang wurde abgebrochen. Bitte erneut versuchen.'
            : 'The operation was cancelled. Please try again.';
      case 'deadline-exceeded':
        return isGerman
            ? 'Die Anfrage hat zu lange gedauert. Bitte erneut versuchen.'
            : 'The request timed out. Please try again.';
      case 'not-found':
        return isGerman
            ? 'Der angeforderte Eintrag wurde nicht gefunden.'
            : 'The requested item was not found.';
      case 'already-exists':
        return isGerman
            ? 'Der Eintrag existiert bereits.'
            : 'The entry already exists.';
      case 'resource-exhausted':
        return isGerman
            ? 'Kontingent erschöpft. Bitte später erneut probieren.'
            : 'Quota exceeded. Please try again later.';
      case 'failed-precondition':
        return isGerman
            ? 'Eine Voraussetzung wurde nicht erfüllt.'
            : 'A precondition was not met.';
    }

    return fallback ?? _defaultMessage(isGerman);
  }

  static bool _isNetworkErrorCode(String code) {
    switch (code) {
      case 'network_error':
      case 'network-request-failed':
      case 'internet_disconnected':
        return true;
      default:
        return false;
    }
  }

  static String _offlineMessage(bool isGerman) {
    return isGerman
        ? 'Keine Internetverbindung. Änderungen werden synchronisiert, sobald du wieder online bist.'
        : 'No internet connection. Changes will sync once you are back online.';
  }

  static String _defaultMessage(bool isGerman) {
    return isGerman
        ? 'Etwas ist schiefgelaufen. Bitte später erneut versuchen.'
        : 'Something went wrong. Please try again later.';
  }
}
