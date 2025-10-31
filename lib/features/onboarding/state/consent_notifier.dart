import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'package:free_base/features/onboarding/models/consent_state.dart';

/// ChangeNotifier that exposes the stored consent state and updates it.
class ConsentNotifier extends ChangeNotifier {
  static const _consentKey = 'consent';

  final Box<ConsentState> _box;
  ConsentState _state;

  ConsentNotifier(
    this._box, {
    String? defaultLocale,
  }) : _state = _box.get(
          _consentKey,
          defaultValue: ConsentState(
            accepted: false,
            acceptedAt: null,
            locale: defaultLocale ?? 'de',
          ),
        ) ??
            ConsentState(
              accepted: false,
              acceptedAt: null,
              locale: defaultLocale ?? 'de',
            );

  ConsentState get state => _state;
  bool get hasAccepted => _state.accepted;

  Future<void> accept({required String locale}) async {
    final updated = _state.copyWith(
      accepted: true,
      acceptedAt: DateTime.now(),
      locale: locale,
    );
    _state = updated;
    await _box.put(_consentKey, updated);
    notifyListeners();
  }

  Future<void> reset() async {
    final resetState = ConsentState(
      accepted: false,
      acceptedAt: null,
      locale: _state.locale,
    );
    _state = resetState;
    await _box.put(_consentKey, resetState);
    notifyListeners();
  }
}
