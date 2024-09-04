import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:quit_smoke/theme/app_theme.dart';

class MonthlyChart extends StatelessWidget {
  final List<Map<String, dynamic>> smokeRecords;

  const MonthlyChart({super.key, required this.smokeRecords});

  @override
  Widget build(BuildContext context) {
    final thisMonthTotal = _getMonthlyTotal(DateTime.now());
    final lastMonthTotal = _getMonthlyTotal(
        DateTime(DateTime.now().year, DateTime.now().month - 1, 1));

    final thisMonthData = _getMonthlyData(DateTime.now());
    final lastMonthData = _getMonthlyData(
        DateTime(DateTime.now().year, DateTime.now().month - 1, 1));

    return Column(
      children: [
        _buildLegend(),
        _buildChart(thisMonthTotal, lastMonthTotal),
        const SizedBox(height: 20),
        _buildComment(thisMonthTotal, lastMonthTotal),
        const SizedBox(height: 20),
        _buildMonthlyTable(thisMonthData, lastMonthData),
        const SizedBox(height: 20),
        _buildCommentDate(thisMonthData, lastMonthData),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(AppTheme.primaryColor, '이번 달'),
        const SizedBox(width: 20),
        _legendItem(AppTheme.accentColor, '지난 달'),
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

  Widget _buildChart(int thisMonthTotal, int lastMonthTotal) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (thisMonthTotal > lastMonthTotal
                  ? thisMonthTotal
                  : lastMonthTotal)
              .toDouble(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value == 0 ? '이번 달' : '지난 달',
                    style: const TextStyle(
                        color: AppTheme.textColor, fontSize: 12),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                        color: AppTheme.textColor, fontSize: 12),
                  );
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                    toY: thisMonthTotal.toDouble(),
                    color: AppTheme.primaryColor),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                    toY: lastMonthTotal.toDouble(),
                    color: AppTheme.accentColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComment(int thisMonthTotal, int lastMonthTotal) {
    final difference = thisMonthTotal - lastMonthTotal;
    String comment;
    if (difference > 0) {
      comment = '지난 달보다 $difference개비 더 피우셨네요. 다음 달엔 줄여보는 게 어떨까요?';
    } else if (difference < 0) {
      comment = '지난 달보다 ${-difference}개비 덜 피우셨어요. 대단해요!';
    } else {
      comment = '지난 달과 동일한 흡연량이에요. 조금씩 줄여나가 보세요!';
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

  int _getMonthlyTotal(DateTime date) {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0);

    return smokeRecords.where((record) {
      final recordDate = DateTime.parse(record['timestamp']);
      return recordDate
              .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          recordDate.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).fold(0, (sum, record) => sum + (record['count'] as int));
  }

  Widget _buildMonthlyTable(
      List<FlSpot> thisMonthData, List<FlSpot> lastMonthData) {
    int maxDate = thisMonthData.length > lastMonthData.length
        ? thisMonthData.length
        : lastMonthData.length;
    return Table(
      border: TableBorder.all(color: AppTheme.subtleTextColor),
      children: [
        TableRow(
          children: [
            _buildTableCell('날짜', isHeader: true),
            _buildTableCell('이번 달', isHeader: true),
            _buildTableCell('지난 달', isHeader: true),
          ],
        ),
        for (int i = 0; i < maxDate; i++)
          TableRow(
            children: [
              _buildTableCell('${i + 1}일'),
              _buildTableCell(
                i < thisMonthData.length
                    ? '${thisMonthData[i].y.toInt()}개비'
                    : '0개비', // 안전하게 0개비로 대체
                isHighlighted: i < thisMonthData.length
                    ? thisMonthData[i].y.toInt() >= 1
                    : false,
              ),
              _buildTableCell(
                i < lastMonthData.length
                    ? '${lastMonthData[i].y.toInt()}개비'
                    : '0개비', // 안전하게 0개비로 대체
                isHighlighted: i < lastMonthData.length
                    ? lastMonthData[i].y.toInt() >= 1
                    : false,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: isHeader
          ? AppTheme.primaryColor
          : isHighlighted
              ? AppTheme.cardEmphasisColor // Highlighted cell color
              : AppTheme.cardColor,
      child: Text(
        text,
        style: TextStyle(
          color: isHeader ? AppTheme.backgroundColor : AppTheme.textColor,
          fontWeight: isHeader
              ? FontWeight.bold
              : isHighlighted
                  ? FontWeight.bold
                  : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCommentDate(
      List<FlSpot> thisMonthData, List<FlSpot> lastMonthData) {
    int thisMonthMaxDay = thisMonthData
        .indexOf(thisMonthData.reduce((a, b) => a.y > b.y ? a : b));
    int lastMonthMaxDay = lastMonthData
        .indexOf(lastMonthData.reduce((a, b) => a.y > b.y ? a : b));

    String comment = '이번 달은 ${thisMonthMaxDay + 1}일에 흡연이 가장 많았고, '
        '지난 달은 ${lastMonthMaxDay + 1}일에 흡연이 가장 많았습니다.\n';

    final thisMonthTotal = thisMonthData.fold(0.0, (sum, spot) => sum + spot.y);
    final lastMonthTotal = lastMonthData.fold(0.0, (sum, spot) => sum + spot.y);
    final difference = thisMonthTotal - lastMonthTotal;

    if (difference > 0) {
      comment +=
          '이번 달에는 지난 달보다 ${difference.toInt()}개비 더 피우셨네요. 다음 달엔 줄여보는 게 어떨까요?';
    } else if (difference < 0) {
      comment += '이번 달에는 지난 달보다 ${(-difference).toInt()}개비 덜 피우셨어요. 대단해요!';
    } else {
      comment += '이번 달은 지난 달과 동일한 흡연량이에요. 조금씩 줄여나가 보세요!';
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

  List<FlSpot> _getMonthlyData(DateTime date) {
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    List<FlSpot> spots =
        List.generate(daysInMonth, (index) => FlSpot(index.toDouble(), 0));

    for (var record in smokeRecords) {
      final recordDate = DateTime.parse(record['timestamp']);
      if (recordDate.year == date.year && recordDate.month == date.month) {
        spots[recordDate.day - 1] = FlSpot(
          (recordDate.day - 1).toDouble(),
          spots[recordDate.day - 1].y + record['count'],
        );
      }
    }

    return spots;
  }
}
