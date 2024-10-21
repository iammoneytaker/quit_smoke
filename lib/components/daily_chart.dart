import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:quitSmoke/theme/app_theme.dart';
import 'package:quitSmoke/utils/user_preferences.dart';
import 'package:quitSmoke/utils/smoke_record_manager.dart';

class DailyChart extends StatefulWidget {
  final List<Map<String, dynamic>> smokeRecords;

  const DailyChart({super.key, required this.smokeRecords});

  @override
  State<DailyChart> createState() => _DailyChartState();
}

class _DailyChartState extends State<DailyChart> {
  int _profileDailyAverage = 0;
  int _todaySmokeCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileAverageAndTodayCount();
  }

  Future<void> _loadProfileAverageAndTodayCount() async {
    final profile = await UserPreferences.getUserProfile();
    final today = DateTime.now();
    final todayRecords = widget.smokeRecords.where((record) {
      final recordDate = DateTime.parse(record['timestamp']);
      return recordDate.year == today.year &&
          recordDate.month == today.month &&
          recordDate.day == today.day;
    }).toList();

    setState(() {
      _profileDailyAverage = profile?['daily_cigarettes'] ?? 0;
      _todaySmokeCount =
          todayRecords.fold(0, (sum, record) => sum + (record['count'] as int));
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final todayData = _getDailyData(today);
    final yesterdayData = _getDailyData(yesterday);

    return Column(
      children: [
        _buildLegend(),
        _buildChart(todayData, yesterdayData),
        const SizedBox(height: 20),
        _buildComment(todayData, yesterdayData),
        const SizedBox(height: 20),
        _buildComparisonCard(),
        const SizedBox(height: 20),
        _buildHourlyTable(todayData),
        const SizedBox(height: 20),
        _buildHourlyComment(todayData),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(AppTheme.primaryColor, '오늘'),
        const SizedBox(width: 20),
        _legendItem(AppTheme.accentColor, '어제'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: AppTheme.textColor)),
      ],
    );
  }

  Widget _buildChart(List<FlSpot> todayData, List<FlSpot> yesterdayData) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString(),
                      style: const TextStyle(
                          color: AppTheme.textColor, fontSize: 12));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 4,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}시',
                      style: const TextStyle(
                          color: AppTheme.textColor, fontSize: 12));
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 23,
          minY: 0,
          clipData: const FlClipData.all(),
          maxY: _getMaxY(todayData, yesterdayData),
          lineBarsData: [
            LineChartBarData(
              spots: todayData,
              // isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
            LineChartBarData(
              spots: yesterdayData,
              // isCurved: true,
              color: AppTheme.accentColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.accentColor.withOpacity(0.2),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: AppTheme.cardColor,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  final isToday = barSpot.barIndex == 0;
                  return LineTooltipItem(
                    '${isToday ? "오늘" : "어제"}: ${flSpot.y.toInt()}개',
                    const TextStyle(color: AppTheme.textColor),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComment(List<FlSpot> todayData, List<FlSpot> yesterdayData) {
    final todayTotal = todayData.fold(0.0, (sum, spot) => sum + spot.y);
    final yesterdayTotal = yesterdayData.fold(0.0, (sum, spot) => sum + spot.y);
    final difference = todayTotal - yesterdayTotal;

    String comment;
    if (difference > 0) {
      comment = '어제보다 ${difference.toInt()}개비 더 피우셨네요. 조금만 더 노력해 보세요!';
    } else if (difference < 0) {
      comment = '어제보다 ${(-difference).toInt()}개비 덜 피우셨어요. 잘 하고 계십니다!';
    } else {
      comment = '어제와 동일한 흡연량이에요. 줄이기 위해 노력해 보세요!';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        comment,
        style: const TextStyle(color: AppTheme.textColor, fontSize: 16),
      ),
    );
  }

  List<FlSpot> _getDailyData(DateTime date) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    List<FlSpot> spots =
        List.generate(24, (index) => FlSpot(index.toDouble(), 0));

    for (var record in widget.smokeRecords) {
      final recordDate = DateTime.parse(record['timestamp']);
      if (DateFormat('yyyy-MM-dd').format(recordDate) == dateString) {
        final hour = recordDate.hour;
        spots[hour] = FlSpot(hour.toDouble(), spots[hour].y + record['count']);
      }
    }

    return spots;
  }

  double _getMaxY(List<FlSpot> data1, List<FlSpot> data2) {
    final maxY1 = data1.fold(0.0, (max, spot) => spot.y > max ? spot.y : max);
    final maxY2 = data2.fold(0.0, (max, spot) => spot.y > max ? spot.y : max);
    final maxY = maxY1 > maxY2 ? maxY1 : maxY2;
    return (maxY / 5).ceil() * 5.0;
  }

  Widget _buildHourlyTable(List<FlSpot> todayData) {
    return Table(
      border: TableBorder.all(color: AppTheme.subtleTextColor),
      children: [
        TableRow(
          children: [
            _buildTableCell('시간대', isHeader: true),
            _buildTableCell('흡연량', isHeader: true),
          ],
        ),
        for (int i = 0; i < 24; i++)
          TableRow(
            children: [
              _buildTableCell('$i시 - ${i + 1}시'),
              _buildTableCell(
                '${todayData[i].y.toInt()}개비',
                isHighlighted: todayData[i].y.toInt() >=
                    1, // Highlight cells with value >= 1
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isHighlighted =
        false, // Add a flag to indicate if the cell should be highlighted
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: isHeader
          ? AppTheme.primaryColor
          : isHighlighted
              ? AppTheme.cardEmphasisColor // Highlighted cell color
              : AppTheme.cardColor, // Default cell color
      child: Text(
        text,
        style: TextStyle(
          color: isHeader ? AppTheme.backgroundColor : AppTheme.textColor,
          fontWeight: isHeader
              ? FontWeight.bold
              : isHighlighted
                  ? FontWeight.bold // Highlighted cell color
                  : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHourlyComment(List<FlSpot> todayData) {
    int maxHour = 0;
    double maxCount = 0;
    for (int i = 0; i < todayData.length; i++) {
      if (todayData[i].y > maxCount) {
        maxCount = todayData[i].y;
        maxHour = i;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '오늘 가장 많이 흡연한 시간대는 $maxHour시 - ${maxHour + 1}시로, ${maxCount.toInt()}개비를 피웠습니다. 이 시간대의 흡연을 줄이는 데 집중해보세요.',
        style: const TextStyle(color: AppTheme.textColor, fontSize: 16),
      ),
    );
  }

  Widget _buildComparisonCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 흡연량 비교',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildComparisonRow('프로필 일일 평균', _profileDailyAverage),
          const SizedBox(height: 8),
          _buildComparisonRow('오늘 흡연량', _todaySmokeCount),
          const SizedBox(height: 16),
          Text(
            _getComparisonComment(),
            style: const TextStyle(color: AppTheme.textColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textColor, fontSize: 16),
        ),
        Text(
          '$value개비',
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getComparisonComment() {
    if (_profileDailyAverage == 0) {
      return '프로필에 일일 평균 흡연량을 설정해 주세요.';
    }

    final percentChange = _profileDailyAverage > 0
        ? ((_todaySmokeCount - _profileDailyAverage) /
                _profileDailyAverage *
                100)
            .toStringAsFixed(1)
        : '0.0';

    if (_todaySmokeCount < _profileDailyAverage) {
      return '축하합니다! 프로필에 기록된 평균보다 $percentChange% 줄어들었어요. 계속 이대로 가시면 금연 성공할 수 있어요!';
    } else if (_todaySmokeCount > _profileDailyAverage) {
      return '프로필에 기록된 평균보다 $percentChange% 증가했어요. 조금 더 노력이 필요해 보입니다. 힘내세요!';
    } else {
      return '프로필에 기록된 평균과 일치해요. 더 줄일 수 있도록 노력해 보세요!';
    }
  }
}
