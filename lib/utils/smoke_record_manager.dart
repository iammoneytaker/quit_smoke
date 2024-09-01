import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SmokeRecordManager {
  static const String _keySmokeRecords = 'smoke_records';

  static Future<void> addSmokeRecord(Map<String, dynamic> record) async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString(_keySmokeRecords);
    List<Map<String, dynamic>> records = [];
    if (recordsJson != null) {
      records = List<Map<String, dynamic>>.from(json.decode(recordsJson));
    }
    records.add(record);
    await prefs.setString(_keySmokeRecords, json.encode(records));
  }

  static Future<List<Map<String, dynamic>>> getSmokeRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString(_keySmokeRecords);
    if (recordsJson != null) {
      return List<Map<String, dynamic>>.from(json.decode(recordsJson));
    }
    return [];
  }

  static Future<void> clearSmokeRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySmokeRecords);
  }

  static Future<int> getTodayCount() async {
    final records = await getSmokeRecords();
    final today = DateTime.now().toIso8601String().split('T')[0];
    int todayCount = 0;
    for (var record in records) {
      if (record['timestamp']?.toString().startsWith(today) ?? false) {
        final count = record['count'];
        if (count is int) {
          todayCount += count;
        } else if (count is String) {
          todayCount += int.tryParse(count) ?? 0;
        }
      }
    }
    return todayCount;
  }

  static Future<DateTime?> getLastSmokeTime() async {
    final records = await getSmokeRecords();
    if (records.isNotEmpty) {
      records.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      final lastRecord = records.first;
      return DateTime.parse(lastRecord['timestamp']);
    }
    return null;
  }
}
