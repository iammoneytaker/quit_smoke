import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:quit_smoke/theme/app_theme.dart';

class WeeklyChart extends StatefulWidget {
  final List<Map<String, dynamic>> smokeRecords;

  const WeeklyChart({super.key, required this.smokeRecords});

  @override
  _WeeklyChartState createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart> {
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getWeekStart(DateTime.now());
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final thisWeekData = _getWeeklyData(_currentWeekStart);
    final lastWeekData =
        _getWeeklyData(_currentWeekStart.subtract(const Duration(days: 7)));

    return Column(
      children: [
        _buildWeekNavigator(),
        _buildLegend(),
        _buildChart(thisWeekData, lastWeekData),
        const SizedBox(height: 20),
        _buildComment(thisWeekData, lastWeekData),
        const SizedBox(height: 20),
        _buildWeeklyTable(thisWeekData, lastWeekData),
        const SizedBox(height: 20),
        _buildCommentDay(thisWeekData, lastWeekData),
      ],
    );
  }

  Widget _buildWeekNavigator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppTheme.textColor),
          onPressed: () {
            setState(() {
              _currentWeekStart =
                  _currentWeekStart.subtract(const Duration(days: 7));
            });
          },
        ),
        Text(
          '${DateFormat('yyyy.MM.dd').format(_currentWeekStart)} - ${DateFormat('yyyy.MM.dd').format(_currentWeekStart.add(const Duration(days: 6)))}',
          style: const TextStyle(color: AppTheme.textColor),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppTheme.textColor),
          onPressed: () {
            final nextWeekStart =
                _currentWeekStart.add(const Duration(days: 7));
            if (nextWeekStart.isBefore(DateTime.now())) {
              setState(() {
                _currentWeekStart = nextWeekStart;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(AppTheme.primaryColor, '이번 주'),
        const SizedBox(width: 20),
        _legendItem(AppTheme.accentColor, '지난 주'),
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

  Widget _buildChart(List<FlSpot> thisWeekData, List<FlSpot> lastWeekData) {
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
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
                  return Text(weekdays[value.toInt()],
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
          maxX: 6,
          minY: 0,
          maxY: _getMaxY(thisWeekData, lastWeekData),
          clipData: const FlClipData.all(),
          lineBarsData: [
            LineChartBarData(
              spots: thisWeekData,
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
            LineChartBarData(
              spots: lastWeekData,
              isCurved: true,
              color: AppTheme.accentColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
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
                  return LineTooltipItem(
                    '${flSpot.y.toInt()}개',
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

  Widget _buildComment(List<FlSpot> thisWeekData, List<FlSpot> lastWeekData) {
    final thisWeekTotal = thisWeekData.fold(0.0, (sum, spot) => sum + spot.y);
    final lastWeekTotal = lastWeekData.fold(0.0, (sum, spot) => sum + spot.y);
    final difference = thisWeekTotal - lastWeekTotal;

    String comment;
    if (difference > 0) {
      comment = '지난 주보다 ${difference.toInt()}개비 더 피우셨네요. 조금만 더 노력해 보세요!';
    } else if (difference < 0) {
      comment = '지난 주보다 ${(-difference).toInt()}개비 덜 피우셨어요. 잘 하고 계십니다!';
    } else {
      comment = '지난 주와 동일한 흡연량이에요. 줄이기 위해 노력해 보세요!';
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

  Widget _buildCommentDay(
      List<FlSpot> thisWeekData, List<FlSpot> lastWeekData) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];

    int thisWeekMaxDay =
        thisWeekData.indexOf(thisWeekData.reduce((a, b) => a.y > b.y ? a : b));
    int lastWeekMaxDay =
        lastWeekData.indexOf(lastWeekData.reduce((a, b) => a.y > b.y ? a : b));

    String comment = '이번 주는 ${weekdays[thisWeekMaxDay]}요일에 흡연이 가장 많았고, '
        '저번 주는 ${weekdays[lastWeekMaxDay]}요일에 흡연이 가장 많았습니다.\n';

    final thisWeekTotal = thisWeekData.fold(0.0, (sum, spot) => sum + spot.y);
    final lastWeekTotal = lastWeekData.fold(0.0, (sum, spot) => sum + spot.y);
    final difference = thisWeekTotal - lastWeekTotal;

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

  List<FlSpot> _getWeeklyData(DateTime weekStart) {
    List<FlSpot> spots = [];
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final count = widget.smokeRecords
          .where((record) =>
              DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(record['timestamp'])) ==
              DateFormat('yyyy-MM-dd').format(day))
          .fold(0, (sum, record) => sum + (record['count'] as int));
      spots.add(FlSpot(i.toDouble(), count.toDouble()));
    }
    return spots;
  }

  double _getMaxY(List<FlSpot> data1, List<FlSpot> data2) {
    final maxY1 = data1.fold(0.0, (max, spot) => spot.y > max ? spot.y : max);
    final maxY2 = data2.fold(0.0, (max, spot) => spot.y > max ? spot.y : max);
    final maxY = maxY1 > maxY2 ? maxY1 : maxY2;
    return (maxY / 5).ceil() * 5.0;
  }

  Widget _buildWeeklyTable(
      List<FlSpot> thisWeekData, List<FlSpot> lastWeekData) {
    return Table(
      border: TableBorder.all(color: AppTheme.subtleTextColor),
      children: [
        TableRow(
          children: [
            _buildTableCell('요일', isHeader: true),
            _buildTableCell('이번 주', isHeader: true),
            _buildTableCell('지난 주', isHeader: true),
          ],
        ),
        for (int i = 0; i < 7; i++)
          TableRow(
            children: [
              _buildTableCell(['월', '화', '수', '목', '금', '토', '일'][i]),
              _buildTableCell('${thisWeekData[i].y.toInt()}개비'),
              _buildTableCell('${lastWeekData[i].y.toInt()}개비'),
            ],
          ),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: isHeader ? AppTheme.primaryColor : AppTheme.cardColor,
      child: Text(
        text,
        style: TextStyle(
          color: isHeader ? AppTheme.backgroundColor : AppTheme.textColor,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
