import 'package:flutter/material.dart';
import 'package:quit_smoke/components/daily_chart.dart';
import 'package:quit_smoke/components/weekly_chart.dart';
import 'package:quit_smoke/components/monthly_chart.dart';
import 'package:quit_smoke/components/custom_period_chart.dart';
import 'package:quit_smoke/theme/app_theme.dart';
import 'package:quit_smoke/utils/smoke_record_manager.dart';

import '../components/hourly_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _currentView = 'daily';
  List<Map<String, dynamic>> _smokeRecords = [];
  bool _hasSmokingRecord = false;

  @override
  void initState() {
    super.initState();
    _loadSmokeRecords();
  }

  Future<void> _loadSmokeRecords() async {
    final records = await SmokeRecordManager.getSmokeRecords();
    final hasRecord = await SmokeRecordManager.hasAnySmokingRecord();
    setState(() {
      _smokeRecords = records;
      _hasSmokingRecord = hasRecord;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('흡연 통계', style: TextStyle(color: AppTheme.textColor)),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: _hasSmokingRecord
          ? Column(
              children: [
                _buildViewSelector(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16),
                      child: _buildCurrentView(),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: Text(
                '흡연을 기록해 주세요!\n통계를 보려면 먼저 흡연을 기록해야 합니다.',
                style: TextStyle(color: AppTheme.textColor, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }

  Widget _buildViewSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedButton<String>(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.primaryColor;
                }
                return AppTheme.cardColor;
              },
            ),
            foregroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.backgroundColor;
                }
                return AppTheme.textColor;
              },
            ),
            visualDensity: const VisualDensity(horizontal: -3, vertical: -2),
          ),
          segments: const [
            ButtonSegment(value: 'daily', label: Text('일간')),
            ButtonSegment(value: 'weekly', label: Text('주간')),
            ButtonSegment(value: 'monthly', label: Text('월간')),
            ButtonSegment(value: 'custom', label: Text('기간')),
            ButtonSegment(value: 'hourly', label: Text('시간')),
          ],
          selected: {_currentView},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              _currentView = newSelection.first;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case 'daily':
        return DailyChart(smokeRecords: _smokeRecords);
      case 'weekly':
        return WeeklyChart(smokeRecords: _smokeRecords);
      case 'monthly':
        return MonthlyChart(smokeRecords: _smokeRecords);
      case 'custom':
        return CustomPeriodChart(smokeRecords: _smokeRecords);
      case 'hourly':
        return HourlyChart(smokeRecords: _smokeRecords);
      default:
        return const SizedBox.shrink();
    }
  }
}
