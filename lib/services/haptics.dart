import 'package:flutter/services.dart';

class Haptics {
  static Future<void> phase() async => HapticFeedback.lightImpact();
  static Future<void> repStart() async => HapticFeedback.mediumImpact();
  static Future<void> repEnd() async => HapticFeedback.selectionClick();
}
