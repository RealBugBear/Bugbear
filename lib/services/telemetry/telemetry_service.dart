import 'dart:developer' as developer;

/// Lightweight abstraction for emitting analytics/telemetry events.
abstract class TelemetryService {
  Future<void> logEvent(
    String name, {
    Map<String, Object?>? properties,
  });

  Future<void> setUserId(String? userId) async {}
  Future<void> setUserProperties(Map<String, Object?> properties) async {}
}

/// Default debug implementation writing events to the developer log.
class DebugTelemetryService implements TelemetryService {
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
}
