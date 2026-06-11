import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class StorageKeys {
  static const String tokens = '@ola:tokens';
  static const String user = '@ola:user';
  static const String recentSearches = '@ola:recent_searches';
  static const String rideHistoryCache = '@ola:ride_history';
  static const String onboardingDone = '@ola:onboarding_done';
  static const String fcmToken = '@ola:fcm_token';
  static const String settings = '@ola:settings';
}

class StorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  StorageService(this._prefs, this._secureStorage);

  Future<void> setTokens(Map<String, dynamic> tokens) async {
    await _secureStorage.write(key: StorageKeys.tokens, value: jsonEncode(tokens));
  }

  Future<Map<String, dynamic>?> getTokens() async {
    final data = await _secureStorage.read(key: StorageKeys.tokens);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: StorageKeys.tokens);
  }

  Future<void> setOnboardingDone() async {
    await _prefs.setBool(StorageKeys.onboardingDone, true);
  }

  bool isOnboardingDone() {
    return _prefs.getBool(StorageKeys.onboardingDone) ?? false;
  }
}
