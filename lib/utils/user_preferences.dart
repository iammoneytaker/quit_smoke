import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserPreferences {
  static const String _keyUserProfile = 'user_profile';
  static const String _keySeenWelcomeScreen = 'seen_welcome_screen';
  static const String _keyStartDate = 'app_start_date';

  static Future<void> saveUserProfile(Map<String, dynamic> userProfile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserProfile, json.encode(userProfile));
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userProfileString = prefs.getString(_keyUserProfile);
    if (userProfileString != null) {
      return json.decode(userProfileString) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserProfile);
  }

  static Future<bool> hasSeenWelcomeScreen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySeenWelcomeScreen) ?? false;
  }

  static Future<void> setSeenWelcomeScreen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySeenWelcomeScreen, true);
  }

  static Future<int> getAppStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    String? startDateString = prefs.getString(_keyStartDate);

    if (startDateString == null) {
      setAppStartDate();
      return 1; // 저장된 날짜가 없으면 0일
    }

    DateTime startDate =
        DateTime.parse(startDateString); // 저장된 날짜를 DateTime 객체로 변환
    DateTime now = DateTime.now(); // 현재 날짜와 시간

    // 현재 날짜와 저장된 날짜 사이의 차이를 계산
    Duration difference = now.difference(startDate);

    return difference.inDays; // 차이의 일수를 반환
  }

  static Future<void> setAppStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    String startDate = DateTime.now().toIso8601String();
    await prefs.setString(_keyStartDate, startDate);
  }
}
