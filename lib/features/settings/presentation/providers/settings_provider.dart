import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  // Defaults
  ThemeMode _themeMode = ThemeMode.system;
  String _currency = 'INR';
  bool _isAppLockEnabled = false;
  int _startOfMonth = 1;
  bool _budgetAlertsEnabled = true;
  bool _monthlySummaryEnabled = true;

  ThemeMode get themeMode => _themeMode;
  String get currency => _currency;
  bool get isAppLockEnabled => _isAppLockEnabled;
  int get startOfMonth => _startOfMonth;
  bool get budgetAlertsEnabled => _budgetAlertsEnabled;
  bool get monthlySummaryEnabled => _monthlySummaryEnabled;

  SettingsProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();

    // Load Theme
    final themeIndex = _prefs?.getInt('theme_mode') ?? 0;
    // 0: system, 1: light, 2: dark
    _themeMode = _indexToThemeMode(themeIndex);

    // Load Currency
    _currency = _prefs?.getString('currency') ?? 'INR';

    // Load App Lock
    _isAppLockEnabled = _prefs?.getBool('app_lock') ?? false;

    // Load Start of Month
    _startOfMonth = _prefs?.getInt('start_of_month') ?? 1;

    // Load Notifications
    _budgetAlertsEnabled = _prefs?.getBool('budget_alerts') ?? true;
    _monthlySummaryEnabled = _prefs?.getBool('monthly_summary') ?? true;

    // _isInitialized = true;
    notifyListeners();
  }

  ThemeMode _indexToThemeMode(int index) {
    switch (index) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      case 0:
      default:
        return ThemeMode.system;
    }
  }

  int _themeModeToIndex(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      case ThemeMode.system:
        return 0;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs?.setInt('theme_mode', _themeModeToIndex(mode));
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    _currency = code;
    await _prefs?.setString('currency', code);
    notifyListeners();
  }

  Future<void> setAppLock(bool enabled) async {
    _isAppLockEnabled = enabled;
    await _prefs?.setBool('app_lock', enabled);
    notifyListeners();
  }

  Future<void> setStartOfMonth(int day) async {
    _startOfMonth = day;
    await _prefs?.setInt('start_of_month', day);
    notifyListeners();
  }

  Future<void> setBudgetAlerts(bool enabled) async {
    _budgetAlertsEnabled = enabled;
    await _prefs?.setBool('budget_alerts', enabled);
    notifyListeners();
  }

  Future<void> setMonthlySummary(bool enabled) async {
    _monthlySummaryEnabled = enabled;
    await _prefs?.setBool('monthly_summary', enabled);
    notifyListeners();
  }

  Future<void> resetSettings() async {
    await _prefs?.clear();
    await _init();
  }
}
