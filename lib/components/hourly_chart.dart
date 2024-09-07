import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quitSmoke/data/ad_data.dart';
import 'package:quitSmoke/theme/app_theme.dart';

class HourlyChart extends StatefulWidget {
  final List<Map<String, dynamic>> smokeRecords;

  const HourlyChart({super.key, required this.smokeRecords});

  @override
  State<HourlyChart> createState() => _HourlyChartState();
}

class _HourlyChartState extends State<HourlyChart> {
  BannerAd? _bannerAd;

  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: BANNER_ADID,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Widget _buildBannerAd() {
    if (!_isBannerAdLoaded) return const SizedBox.shrink();

    return Card(
      color: AppTheme.cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: _bannerAd!.size.width.toDouble(),
        height: 72.0,
        alignment: Alignment.center,
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hourlyData = _getHourlyData();

    return Column(
      children: [
        const SizedBox(height: 20),
        _buildChart(hourlyData),
        const SizedBox(height: 20),
        if (_isBannerAdLoaded) _buildBannerAd(),
        const SizedBox(height: 20),
        _buildHourlyTable(hourlyData),
        const SizedBox(height: 20),
        _buildComment(hourlyData),
      ],
    );
  }

  Widget _buildChart(List<FlSpot> hourlyData) {
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
          maxY:
              hourlyData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b),
          clipData: const FlClipData.all(),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: AppTheme.cardColor,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  return LineTooltipItem(
                    '${flSpot.x.toInt()}시: ${flSpot.y.toInt()}개',
                    const TextStyle(color: AppTheme.textColor),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: hourlyData,
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
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyTable(List<FlSpot> hourlyData) {
    return Table(
      border: TableBorder.all(color: AppTheme.subtleTextColor),
      children: [
        TableRow(
          children: [
            _buildTableCell('시간대', isHeader: true),
            _buildTableCell('총 흡연량', isHeader: true),
          ],
        ),
        for (int i = 0; i < 24; i++)
          TableRow(
            children: [
              _buildTableCell('$i시 - ${i + 1}시'),
              _buildTableCell('${hourlyData[i].y.toInt()}개비',
                  isHighlighted: hourlyData[i].y.toInt() >= 1),
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

  Widget _buildComment(List<FlSpot> hourlyData) {
    int maxHour = 0;
    double maxCount = 0;
    for (int i = 0; i < hourlyData.length; i++) {
      if (hourlyData[i].y > maxCount) {
        maxCount = hourlyData[i].y;
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
        '전체적으로 가장 많이 흡연한 시간대는 $maxHour시 - ${maxHour + 1}시로, 총 ${maxCount.toInt()}개비를 피웠습니다. 이 시간대의 흡연 습관을 개선하는 데 집중해보세요.',
        style: const TextStyle(color: AppTheme.textColor, fontSize: 16),
      ),
    );
  }

  List<FlSpot> _getHourlyData() {
    List<FlSpot> spots =
        List.generate(24, (index) => FlSpot(index.toDouble(), 0));

    for (var record in widget.smokeRecords) {
      final recordDate = DateTime.parse(record['timestamp']);
      final hour = recordDate.hour;
      spots[hour] = FlSpot(hour.toDouble(), spots[hour].y + record['count']);
    }

    return spots;
  }
}
