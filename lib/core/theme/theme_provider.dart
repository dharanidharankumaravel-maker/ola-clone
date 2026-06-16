import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/storage_provider.dart';
import 'app_colors.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  late SharedPreferences _prefs;
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    final stored = _prefs.getString(_key);
    if (stored == 'light') {
      AppColors.isDark = false;
      return ThemeMode.light;
    } else {
      AppColors.isDark = true;
      return ThemeMode.dark;
    }
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      AppColors.isDark = false;
      _prefs.setString(_key, 'light');
    } else {
      state = ThemeMode.dark;
      AppColors.isDark = true;
      _prefs.setString(_key, 'dark');
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    AppColors.isDark = mode == ThemeMode.dark;
    _prefs.setString(_key, mode == ThemeMode.dark ? 'dark' : 'light');
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});
