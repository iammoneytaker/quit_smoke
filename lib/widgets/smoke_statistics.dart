import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmokeStatistics extends StatelessWidget {
  const SmokeStatistics({super.key});

  Future<List<Map<String, dynamic>>> _getSmokeRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString('smoke_records');
    if (recordsJson != null) {
      final List<dynamic> decoded = json.decode(recordsJson);
      return List<Map<String, dynamic>>.from(decoded);
    }
    return [];
  }

  List<BarChartGroupData> _getWeeklyData(
      List<Map<String, dynamic>> smokeRecords) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      final count = smokeRecords
          .where((record) =>
              DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(record['timestamp'])) ==
              DateFormat('yyyy-MM-dd').format(date))
          .fold(0, (sum, record) => sum + (record['cigarette_count'] as int));

      return BarChartGroupData(
        x: index,
        barRods: [BarChartRodData(toY: count.toDouble())],
      );
    });
  }

  double _getMaxY(List<BarChartGroupData> data) {
    final maxY = data.fold(
        0.0,
        (max, group) =>
            group.barRods.first.toY > max ? group.barRods.first.toY : max);
    return (maxY / 5).ceil() * 5.0;
  }

  int _getTodaySmokingCount(List<Map<String, dynamic>> smokeRecords) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return smokeRecords
        .where((record) =>
            DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(record['timestamp'])) ==
            today)
        .fold(0, (sum, record) => sum + (record['cigarette_count'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getSmokeRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final smokeRecords = snapshot.data ?? [];
        final weeklyData = _getWeeklyData(smokeRecords);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '주간 흡연량',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(weeklyData),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
                          return Text(weekdays[value.toInt()]);
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 5,
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: weeklyData,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '오늘의 흡연량: ${_getTodaySmokingCount(smokeRecords)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        );
      },
    );
  }
}
