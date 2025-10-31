import 'dart:developer' as developer;

/// Lightweight abstraction for emitting analytics/telemetry events.
abstract class TelemetryService {
  Future<void> logEvent(
    String name, {
    Map<String, Object?>? properties,
  });

  Future<void> setUserId(String? userId);

  Future<void> setUserProperties(Map<String, Object?> properties);
}

/// Default debug implementation writing events to the developer log.
class DebugTelemetryService implements TelemetryService {
  String? _userId;
  Map<String, Object?> _userProperties = const {};

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?>? properties,
  }) async {
    final payload = properties == null || properties.isEmpty
        ? ''
        : properties.entries
            .map((entry) => '${entry.key}=${entry.value}')
            .join(', ');
    developer.log(
      'event:$name${payload.isEmpty ? '' : ' {$payload}'}',
      name: 'telemetry',
    );
  }

  @override
  Future<void> setUserId(String? userId) async {
    _userId = userId;
    developer.log(
      'userId:${userId ?? 'anonymous'}',
      name: 'telemetry',
    );
  }

  @override
  Future<void> setUserProperties(Map<String, Object?> properties) async {
    _userProperties = Map.unmodifiable(properties);
    final payload = _userProperties.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join(', ');
    developer.log(
      'userProperties{${payload.isEmpty ? 'empty' : payload}}',
      name: 'telemetry',
    );
  }

  /// Exposes the last user id recorded during debugging or tests.
  String? get debugUserId => _userId;

  /// Exposes the last set of user properties recorded during debugging or tests.
  Map<String, Object?> get debugUserProperties => _userProperties;
}
