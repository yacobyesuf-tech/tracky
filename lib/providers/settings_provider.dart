import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/services/haptic_service.dart';
import '../core/services/biometric_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isHapticsEnabled = true;
  bool _isBiometricsEnabled = false;
  String _currencySymbol = '\$';
  bool _isInitialized = false;

  bool get isHapticsEnabled => _isHapticsEnabled;
  bool get isBiometricsEnabled => _isBiometricsEnabled;
  String get currencySymbol => _currencySymbol;
  bool get isInitialized => _isInitialized;

  static const List<String> availableCurrencies = [
    '\$', '€', '£', '¥', '₹', 'C\$', 'A\$', 'CHF', 'kr', 'R\$'
  ];

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isHapticsEnabled = prefs.getBool(AppConstants.keyHapticsEnabled) ?? true;
      _isBiometricsEnabled = prefs.getBool(AppConstants.keyBiometricsEnabled) ?? false;
      _currencySymbol = prefs.getString(AppConstants.keyCurrencySymbol) ?? '\$';
      HapticService.isEnabled = _isHapticsEnabled;
    } catch (_) {}
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> toggleHaptics(bool value) async {
    _isHapticsEnabled = value;
    HapticService.isEnabled = value;
    if (value) HapticService.lightImpact();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyHapticsEnabled, value);
  }

  Future<bool> toggleBiometrics(bool value) async {
    if (value) {
      final canAuth = await BiometricService.authenticate(
        reason: 'Verify your identity to enable Biometric Lock',
      );
      if (!canAuth) return false;
    }
    _isBiometricsEnabled = value;
    HapticService.selectionClick();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyBiometricsEnabled, value);
    return true;
  }

  Future<void> setCurrency(String symbol) async {
    _currencySymbol = symbol;
    HapticService.selectionClick();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyCurrencySymbol, symbol);
  }
}
