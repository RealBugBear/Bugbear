import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// ReminderService
///
/// Initialisiert `flutter_local_notifications` und stellt Methoden zur
/// Verfügung, um tägliche Erinnerungen für das Training zu planen oder
/// wieder zu löschen.
class ReminderService extends ChangeNotifier {
  ReminderService({FlutterLocalNotificationsPlugin? plugin})
      : _notifications = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _notifications;
  bool _initialized = false;
  bool _timeZonesInitialized = false;
  TimeOfDay? _scheduledTime;

  TimeOfDay? get scheduledTime => _scheduledTime;
  bool get hasScheduledReminder => _scheduledTime != null;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    final androidSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(initializationSettings);
    _initialized = true;
  }

  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await initialize();
    _ensureTimeZones();
    final scheduleDate = _nextInstance(time);
    const androidDetails = AndroidNotificationDetails(
      'training_reminders',
      'Trainingserinnerungen',
      channelDescription: 'Lokale Erinnerung für tägliche Trainingseinheiten.',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.zonedSchedule(
      1000,
      'Zeit für dein Training',
      'Plane jetzt deine nächste Einheit.',
      scheduleDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    _scheduledTime = time;
    notifyListeners();
  }

  Future<void> cancelDailyReminder() async {
    await initialize();
    await _notifications.cancel(1000);
    if (_scheduledTime != null) {
      _scheduledTime = null;
      notifyListeners();
    }
  }

  void _ensureTimeZones() {
    if (_timeZonesInitialized) {
      return;
    }
    tz.initializeTimeZones();
    _timeZonesInitialized = true;
  }

  tz.TZDateTime _nextInstance(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
