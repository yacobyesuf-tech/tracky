class AppConstants {
  static const String appName = 'ExpenseFlow';
  static const String dbName = 'expense_flow_v1.db';
  static const int dbVersion = 1;
  static const String tableExpenses = 'expenses';
  
  // SharedPreferences Keys
  static const String keyThemePreset = 'pref_theme_preset';
  static const String keyIsCustomTheme = 'pref_is_custom_theme';
  static const String keyCustomPrimary = 'pref_custom_primary';
  static const String keyCustomAccent = 'pref_custom_accent';
  static const String keyIsDarkMode = 'pref_is_dark_mode';
  static const String keyHapticsEnabled = 'pref_haptics_enabled';
  static const String keyBiometricsEnabled = 'pref_biometrics_enabled';
  static const String keyCurrencySymbol = 'pref_currency_symbol';
}
