import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quitSmoke/screens/onboarding_screen.dart';
import 'package:quitSmoke/theme/app_theme.dart';
import 'package:quitSmoke/utils/smoke_record_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:quitSmoke/utils/user_preferences.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final InAppReview inAppReview = InAppReview.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cardColor,
      appBar: AppBar(
        title: const Text('설정'),
        foregroundColor: AppTheme.textColor,
        backgroundColor: AppTheme.cardColor,
      ),
      body: ListView(
        children: [
          _buildListTile('초기화', Icons.refresh, _showInitialResetConfirmation),
          const Divider(color: Colors.white),
          _buildListTile('앱 공유하기', Icons.share, _shareApp),
          const Divider(color: Colors.white),
          _buildListTile('리뷰 남기기', Icons.rate_review, _requestReview),
          const Divider(color: Colors.white),
          _buildListTile('개발자에게 문의하기', Icons.mail, _contactDeveloper),
          const Divider(color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: AppTheme.textColor)),
      trailing: Icon(icon, color: AppTheme.textColor),
      onTap: onTap,
    );
  }

  void _showInitialResetConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title:
              const Text('초기화 확인', style: TextStyle(color: AppTheme.textColor)),
          content: const Text('모든 절연 관련 기록이 삭제됩니다. 계속하시겠습니까?',
              style: TextStyle(color: AppTheme.textColor)),
          actions: <Widget>[
            TextButton(
              child: const Text('취소',
                  style: TextStyle(color: AppTheme.primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('초기화',
                  style: TextStyle(color: AppTheme.primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
                _resetApp();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetApp() async {
    await SmokeRecordManager.clearSmokeRecords();
    await UserPreferences.clearUserProfile(); // 사용자 프로필 데이터 삭제

    // 앱 재시작
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('모든 데이터가 초기화되었습니다. 다시 시작합니다.',
            style: TextStyle(color: AppTheme.backgroundColor)),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _shareApp() {
    String message = '금연하기 전에 절연부터 시작해볼래요?\n';
    if (Platform.isAndroid) {
      message +=
          'Android: [https://play.google.com/store/apps/details?id=com.moneytaker.quitSmoke]\n';
    }
    if (Platform.isIOS) {
      message += 'iOS: [https://apps.apple.com/app/id6670561435]\n';
    }
    message += '함께 절연부터 도전해봐요!!';

    Share.share(message);
  }

  void _requestReview() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('리뷰 요청을 할 수 없습니다. 잠시 후 다시 시도해주세요.',
              style: TextStyle(color: AppTheme.backgroundColor)),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  void _contactDeveloper() async {
    final Email email = Email(
      body: '',
      subject: '금연말고절연 앱 문의사항',
      recipients: ['sangwon2618@gmail.com'],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일 앱을 열 수 없습니다',
              style: TextStyle(color: AppTheme.backgroundColor)),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  // _launchURL 메서드 제거 (더 이상 사용하지 않음)
}
