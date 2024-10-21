import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../utils/user_preferences.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  _SavingsScreenState createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  int _smokingYears = 0;
  int _cigarettesPerDay = 0;
  double _pricePerPack = 4500.0;
  double _totalSpent = 0.0;
  double _nasdaqInvestment = 0.0;
  double _sp500Investment = 0.0;

  final double _nasdaqAnnualReturn = 0.138;
  final double _sp500AnnualReturn = 0.102;

  final Map<String, double> _stockReturns = {
    'Tesla': 0.475,
    'Apple': 0.253,
    'Microsoft': 0.255,
    'Google': 0.174,
    'Meta': 0.204,
  };

  Map<String, double> _stockInvestments = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await UserPreferences.getUserProfile();
    setState(() {
      _smokingYears = profile?['smoking_years'] ?? 0;
      _cigarettesPerDay = profile?['daily_cigarettes'] ?? 0;
      _pricePerPack = profile?['price_per_pack']?.toDouble() ?? 4500.0;
      _calculateSavings();
      _calculateInvestments();
    });
  }

  void _calculateSavings() {
    final daysSmoked = _smokingYears * 365;
    const cigarettesPerPack = 20;

    _totalSpent =
        (daysSmoked * _cigarettesPerDay * _pricePerPack) / cigarettesPerPack;
  }

  void _calculateInvestments() {
    final yearsSmoking = _smokingYears.toDouble();
    final monthlySpending = (_cigarettesPerDay * _pricePerPack * 30) / 20;

    _nasdaqInvestment = _calculateCompoundInvestment(
        monthlySpending, yearsSmoking * 12, _nasdaqAnnualReturn / 12);
    _sp500Investment = _calculateCompoundInvestment(
        monthlySpending, yearsSmoking * 12, _sp500AnnualReturn / 12);

    _stockInvestments = {};
    for (var entry in _stockReturns.entries) {
      _stockInvestments[entry.key] = _calculateCompoundInvestment(
          monthlySpending, yearsSmoking * 12, entry.value / 12);
    }
  }

  double _calculateCompoundInvestment(
      double monthlyAmount, double months, double monthlyReturn) {
    double totalInvestment = 0;
    for (int i = 0; i < months.floor(); i++) {
      totalInvestment = (totalInvestment + monthlyAmount) * (1 + monthlyReturn);
    }
    final partialMonth = months - months.floor();
    totalInvestment += monthlyAmount * partialMonth;
    return totalInvestment;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('흡연 비용 투자 시뮬레이션'),
        backgroundColor: AppTheme.cardColor,
      ),
      body: Container(
        color: AppTheme.backgroundColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard('총 흡연 비용', _totalSpent, Colors.red),
                const SizedBox(height: 16),
                _buildInvestmentComparison(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, double amount, Color color) {
    final formatter = NumberFormat('#,###');
    return Card(
      color: AppTheme.cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: AppTheme.textColor, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '${formatter.format(amount.round())}원',
              style: TextStyle(
                  color: color, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '(프로필 정보 기준: $_smokingYears년 동안 일일 평균 $_cigarettesPerDay개비 흡연)',
              style: TextStyle(
                  color: AppTheme.textColor.withOpacity(0.7), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentComparison() {
    return Card(
      color: AppTheme.cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '흡연 비용 투자 비교',
              style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildIndexFundsCard(),
            const SizedBox(height: 16),
            ..._stockInvestments.entries.map((entry) => Column(
                  children: [
                    _buildStockCard(
                        entry.key, entry.value, _stockReturns[entry.key]!),
                    const SizedBox(height: 16),
                  ],
                )),
            _buildDisclaimerCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndexFundsCard() {
    return Card(
      color: AppTheme.cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '인덱스 펀드 투자 시나리오',
              style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailedInvestmentItem(
                '나스닥', _nasdaqInvestment, _nasdaqAnnualReturn, Colors.blue),
            Text(
              '* 나스닥의 연평균 수익률: ${(_nasdaqAnnualReturn * 100).toStringAsFixed(2)}%',
              style: TextStyle(
                  color: AppTheme.textColor.withOpacity(0.7), fontSize: 12),
            ),
            const SizedBox(height: 12),
            _buildDetailedInvestmentItem(
                'S&P 500', _sp500Investment, _sp500AnnualReturn, Colors.green),
            Text(
              '* S&P 500의 연평균 수익률: ${(_sp500AnnualReturn * 100).toStringAsFixed(2)}%',
              style: TextStyle(
                  color: AppTheme.textColor.withOpacity(0.7), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard(
      String stockName, double investment, double annualReturn) {
    Color color = _getRandomColor();
    return Card(
      color: AppTheme.cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$stockName 투자 시나리오',
              style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailedInvestmentItem(
                stockName, investment, annualReturn, color),
            const SizedBox(height: 8),
            Text(
              '* $stockName의 연평균 수익률: ${(annualReturn * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                  color: AppTheme.textColor.withOpacity(0.7), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Card(
      color: AppTheme.cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '* 이 계산은 최근 10년 과거 수익률을 바탕으로 월 적립식으로 투자를 한 추정치입니다. 실제 투자 결과는 다를 수 있으며, 과거의 성과가 미래의 수익을 보장하지 않습니다. 금연 동기부여 용도로 재미로만 봐주세요.',
          style: TextStyle(
              color: AppTheme.textColor.withOpacity(0.7),
              fontSize: 12,
              fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildDetailedInvestmentItem(
      String title, double amount, double returnRate, Color color) {
    final formatter = NumberFormat('#,###');
    final profit = amount - _totalSpent;
    final profitRate = (_totalSpent > 0) ? (amount / _totalSpent - 1) * 100 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title 투자 시:',
          style: TextStyle(
              color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          '총 금액: ${formatter.format(amount.round())}원',
          style: const TextStyle(color: AppTheme.textColor, fontSize: 14),
        ),
        Text(
          '수익금: ${formatter.format(profit.round())}원 (${profitRate.toStringAsFixed(2)}% 수익)',
          style: TextStyle(
              color: profit >= 0 ? Colors.green : Colors.red, fontSize: 14),
        ),
      ],
    );
  }

  Color _getRandomColor() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
        .withOpacity(1.0);
  }
}
