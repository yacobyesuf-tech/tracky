import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'theme_presets.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  PresetThemeData _activePreset = AppThemePresets.presets[0];
  bool _isCustomTheme = false;
  Color _customPrimary = const Color(0xFF0D5C3A);
  Color _customAccent = const Color(0xFF00E676);
  bool _isDarkMode = true;
  bool _isInitialized = false;

  PresetThemeData get activePreset => _activePreset;
  bool get isCustomTheme => _isCustomTheme;
  Color get primaryColor => _isCustomTheme ? _customPrimary : _activePreset.primary;
  Color get accentColor => _isCustomTheme ? _customAccent : _activePreset.accent;
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  Color get customPrimary => _customPrimary;
  Color get customAccent => _customAccent;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(AppConstants.keyIsDarkMode) ?? true;
      _isCustomTheme = prefs.getBool(AppConstants.keyIsCustomTheme) ?? false;
      
      final presetId = prefs.getString(AppConstants.keyThemePreset);
      if (presetId != null) {
        _activePreset = AppThemePresets.getById(presetId);
      }

      final primaryVal = prefs.getInt(AppConstants.keyCustomPrimary);
      final accentVal = prefs.getInt(AppConstants.keyCustomAccent);
      if (primaryVal != null) _customPrimary = Color(primaryVal);
      if (accentVal != null) _customAccent = Color(accentVal);
    } catch (_) {}
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setPreset(PresetThemeData preset) async {
    _activePreset = preset;
    _isCustomTheme = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyThemePreset, preset.id);
    await prefs.setBool(AppConstants.keyIsCustomTheme, false);
  }

  Future<void> setCustomColors({required Color primary, required Color accent}) async {
    _customPrimary = primary;
    _customAccent = accent;
    _isCustomTheme = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsCustomTheme, true);
    await prefs.setInt(AppConstants.keyCustomPrimary, primary.value);
    await prefs.setInt(AppConstants.keyCustomAccent, accent.value);
  }

  Future<void> toggleDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsDarkMode, isDark);
  }

  ThemeData get themeData {
    if (_isCustomTheme) {
      return AppTheme.buildTheme(
        primary: _customPrimary,
        accent: _customAccent,
        isDark: _isDarkMode,
      );
    } else {
      return AppTheme.buildTheme(
        primary: _activePreset.primary,
        accent: _activePreset.accent,
        isDark: _isDarkMode,
        surfaceDark: _activePreset.surfaceDark,
        backgroundDark: _activePreset.backgroundDark,
      );
    }
  }

  List<Color> get chartPalette {
    return [
      accentColor,
      const Color(0xFFFF7043),
      const Color(0xFFAB47BC),
      const Color(0xFF42A5F5),
      const Color(0xFFFFCA28),
      const Color(0xFF26A69A),
      const Color(0xFFEF5350),
      const Color(0xFF5C6BC0),
      const Color(0xFF66BB6A),
      const Color(0xFF29B6F6),
    ];
  }
}
