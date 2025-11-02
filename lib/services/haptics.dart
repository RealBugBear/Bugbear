import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Haptics {
  static bool? _isSupportedCache;
  static bool _loggedUnsupported = false;

  static Future<void> phase() => _run(() => HapticFeedback.lightImpact());
  static Future<void> repStart() => _run(() => HapticFeedback.mediumImpact());
  static Future<void> repEnd() => _run(() => HapticFeedback.selectionClick());

  static Future<void> _run(Future<void> Function() action) async {
    if (!_supportsHaptics) return;
    try {
      await action();
    } on MissingPluginException catch (err) {
      _logOnce(err);
    } on PlatformException catch (err) {
      _logOnce(err);
    }
  }

  static bool get _supportsHaptics {
    final cached = _isSupportedCache;
    if (cached != null) return cached;

    final supported = !kIsWeb &&
        switch (defaultTargetPlatform) {
          TargetPlatform.android ||
          TargetPlatform.iOS ||
          TargetPlatform.macOS => true,
          _ => false,
        };
    _isSupportedCache = supported;
    return supported;
  }

  static void _logOnce(Exception err) {
    if (_loggedUnsupported) return;
    _loggedUnsupported = true;
    debugPrint('Haptics unavailable: $err');
  }
}
