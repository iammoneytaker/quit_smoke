import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:quit_smoke/theme/app_theme.dart';

class CustomPeriodChart extends StatefulWidget {
  final List<Map<String, dynamic>> smokeRecords;

  const CustomPeriodChart({super.key, required this.smokeRecords});

  @override
  _CustomPeriodChartState createState() => _CustomPeriodChartState();
}

class _CustomPeriodChartState extends State<CustomPeriodChart> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<FlSpot> _chartData = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDatePicker(),
        if (_startDate != null && _endDate != null) ...[
          const SizedBox(height: 20),
          _buildChart(),
          const SizedBox(height: 20),
          _buildComment(),
        ],
      ],
    );
  }

  Widget _buildDatePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _startDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _startDate = picked;
                _updateChartData();
              });
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: AppTheme.accentColor,
            backgroundColor: AppTheme.cardColor, // 텍스트 색상
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // 둥근 테두리
            ),
          ),
          child: Text(_startDate == null
              ? '시작일 선택'
              : DateFormat('yyyy-MM-dd').format(_startDate!)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.red,
            backgroundColor: AppTheme.cardColor, // 텍스트 색상
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // 둥근 테두리
            ),
          ),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _endDate ?? DateTime.now(),
              firstDate: _startDate ?? DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _endDate = picked;
                _updateChartData();
              });
            }
          },
          child: Text(_endDate == null
              ? '종료일 선택'
              : DateFormat('yyyy-MM-dd').format(_endDate!)),
        ),
      ],
    );
  }

  Widget _buildChart() {
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
                interval: (_chartData.length / 5).ceil().toDouble(),
                getTitlesWidget: (value, meta) {
                  final date = _startDate!.add(Duration(days: value.toInt()));
                  return Text(DateFormat('MM/dd').format(date),
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
          maxX: _chartData.length.toDouble() - 1,
          minY: 0,
          maxY:
              _chartData.fold(0.0, (max, spot) => spot.y > max! ? spot.y : max),
          clipData: const FlClipData.all(),
          lineBarsData: [
            LineChartBarData(
              spots: _chartData,
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: AppTheme.cardColor,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  final date =
                      _startDate!.add(Duration(days: flSpot.x.toInt()));
                  return LineTooltipItem(
                    '${DateFormat('yyyy-MM-dd').format(date)}: ${flSpot.y.toInt()}개',
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

  Widget _buildComment() {
    final totalSmokes = _chartData.fold(0.0, (sum, spot) => sum + spot.y);
    final days = _endDate!.difference(_startDate!).inDays + 1;
    final average = totalSmokes / days;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '선택한 기간 동안 총 ${totalSmokes.toInt()}개비를 피우셨어요.\n'
        '일평균 ${average.toStringAsFixed(1)}개비를 피우셨습니다.',
        style: const TextStyle(color: AppTheme.textColor, fontSize: 16),
      ),
    );
  }

  void _updateChartData() {
    if (_startDate == null || _endDate == null) return;

    _chartData = [];
    for (int i = 0; i <= _endDate!.difference(_startDate!).inDays; i++) {
      final day = _startDate!.add(Duration(days: i));
      final count = widget.smokeRecords
          .where((record) =>
              DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(record['timestamp'])) ==
              DateFormat('yyyy-MM-dd').format(day))
          .fold(0, (sum, record) => sum + (record['count'] as int));
      _chartData.add(FlSpot(i.toDouble(), count.toDouble()));
    }
  }
}
