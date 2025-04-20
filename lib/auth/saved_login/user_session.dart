import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// Conditionally import dart:html for web
import 'web_storage.dart' if (dart.library.io) 'mock_web_storage.dart';

class UserSession {
  // Keys for SharedPreferences
  static const String TOKEN_KEY = 'token';
  static const String PHONE_KEY = 'phone';
  static const String IS_LOGGED_IN_KEY = 'is_logged_in';
  static const String LAST_ACTIVE_TIME_KEY = 'last_active_time';

  // Save user session with metadata
  static Future<void> saveSession(String token, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
    await prefs.setString(PHONE_KEY, phone);
    await prefs.setBool(IS_LOGGED_IN_KEY, true);
    await prefs.setString(
        LAST_ACTIVE_TIME_KEY, DateTime.now().toIso8601String());

    // Web specific storage to ensure persistence
    if (kIsWeb) {
      WebStorage.setItem(TOKEN_KEY, token);
      WebStorage.setItem(PHONE_KEY, phone);
      WebStorage.setItem(IS_LOGGED_IN_KEY, 'true');
      WebStorage.setItem(
          LAST_ACTIVE_TIME_KEY, DateTime.now().toIso8601String());
    }
  }

  // Get token with web fallback
  static Future<String?> getToken() async {
    // For web, try localStorage first
    if (kIsWeb) {
      final webToken = WebStorage.getItem(TOKEN_KEY);
      if (webToken != null && webToken.isNotEmpty) {
        return webToken;
      }
    }

    // Fall back to shared preferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(TOKEN_KEY);
  }

  // Get phone with web fallback
  static Future<String?> getPhone() async {
    // For web, try localStorage first
    if (kIsWeb) {
      final webPhone = WebStorage.getItem(PHONE_KEY);
      if (webPhone != null && webPhone.isNotEmpty) {
        return webPhone;
      }
    }

    // Fall back to shared preferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PHONE_KEY);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear session data (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
    await prefs.remove(PHONE_KEY);
    await prefs.remove(IS_LOGGED_IN_KEY);
    await prefs.remove(LAST_ACTIVE_TIME_KEY);

    if (kIsWeb) {
      WebStorage.removeItem(TOKEN_KEY);
      WebStorage.removeItem(PHONE_KEY);
      WebStorage.removeItem(IS_LOGGED_IN_KEY);
      WebStorage.removeItem(LAST_ACTIVE_TIME_KEY);
    }
  }

  // Update last active time
  static Future<void> updateLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        LAST_ACTIVE_TIME_KEY, DateTime.now().toIso8601String());

    if (kIsWeb) {
      WebStorage.setItem(
          LAST_ACTIVE_TIME_KEY, DateTime.now().toIso8601String());
    }
  }
}
