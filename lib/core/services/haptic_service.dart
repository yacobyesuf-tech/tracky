import 'package:flutter/services.dart';

class HapticService {
  static bool isEnabled = true;

  static void lightImpact() {
    if (!isEnabled) return;
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    if (!isEnabled) return;
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    if (!isEnabled) return;
    HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    if (!isEnabled) return;
    HapticFeedback.selectionClick();
  }

  static void vibrate() {
    if (!isEnabled) return;
    HapticFeedback.vibrate();
  }
}
