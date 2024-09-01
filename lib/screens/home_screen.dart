import 'package:flutter/material.dart';
import 'dart:async';
import 'package:quit_smoke/utils/smoke_record_manager.dart';
import 'package:quit_smoke/utils/user_preferences.dart';
import 'package:quit_smoke/utils/motivation_messages.dart';
import 'package:quit_smoke/utils/health_benefits.dart';
import 'package:quit_smoke/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _todayCount = 0;
  String _motivationMessage = '';
  DateTime? _lastSmokeTime;
  String _timeSinceLastSmoke = '';
  String _currentBenefit = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final profile = await UserPreferences.getUserProfile();
    final todayCount = await SmokeRecordManager.getTodayCount();
    final lastSmoke = await SmokeRecordManager.getLastSmokeTime();
    final message = await MotivationMessages.getRandomMessage(
        profile?['nickname'] ?? '사용자');

    setState(() {
      _todayCount = todayCount;
      _lastSmokeTime = lastSmoke;
      _motivationMessage = message;
    });

    _updateTimeSinceLastSmoke();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeSinceLastSmoke();
    });
  }

  void _updateTimeSinceLastSmoke() {
    if (_lastSmokeTime != null) {
      final difference = DateTime.now().difference(_lastSmokeTime!);
      setState(() {
        _timeSinceLastSmoke =
            '${difference.inHours}시간 ${difference.inMinutes % 60}분 ${difference.inSeconds % 60}초';
        _currentBenefit = HealthBenefits.getBenefitForDuration(difference);
      });
    }
  }

  void _updateSmokeCount(int change) async {
    final newCount = _todayCount + change;
    if (newCount >= 0) {
      setState(() {
        _todayCount = newCount;
        if (change > 0) {
          _lastSmokeTime = DateTime.now();
          SmokeRecordManager.addSmokeRecord({
            'timestamp': DateTime.now().toIso8601String(),
            'count': change,
          });
        } else if (change < 0 && _todayCount >= 0) {
          // 흡연 기록에서 가장 최근 기록을 제거
          SmokeRecordManager.removeLastSmokeRecord();
        }
      });
      _updateTimeSinceLastSmoke();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildMotivationCard(),
            const SizedBox(height: 24),
            _buildSmokeCountCard(),
            const SizedBox(height: 24),
            _buildTimeSinceLastSmokeCard(),
            const SizedBox(height: 24),
            _buildHealthBenefitCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationCard() {
    return Card(
      color: AppTheme.cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _motivationMessage,
          style: const TextStyle(color: AppTheme.textColor, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildSmokeCountCard() {
    return Card(
      color: AppTheme.cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '오늘의 흡연량',
              style: TextStyle(color: AppTheme.textColor, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              '$_todayCount개비',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCountButton(Icons.remove, () => _updateSmokeCount(-1),
                    Colors.redAccent),
                _buildCountButton(Icons.add, () => _updateSmokeCount(1),
                    AppTheme.accentColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountButton(IconData icon, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: color,
        padding: const EdgeInsets.all(16),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildTimeSinceLastSmokeCard() {
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
              '마지막 흡연 후 경과 시간',
              style: TextStyle(color: AppTheme.textColor, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _timeSinceLastSmoke,
              style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthBenefitCard() {
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
              '현재 건강 개선 효과',
              style: TextStyle(color: AppTheme.textColor, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _currentBenefit,
              style: const TextStyle(
                  color: AppTheme.subtleTextColor, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
