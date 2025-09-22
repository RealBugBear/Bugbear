import 'package:flutter/services.dart';

class Haptics {
  Haptics._();

  static Future<void> phase() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> repStart() async {
    await HapticFeedback.mediumImpact();
  }

  static Future<void> repEnd() async {
    await HapticFeedback.selectionClick();
  }
}
