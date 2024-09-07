import 'package:flutter/material.dart';
import 'package:quitSmoke/theme/app_theme.dart';
import 'package:quitSmoke/utils/smoke_record_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final InAppReview inAppReview = InAppReview.instance;

  @override
  void initState() {
    super.initState();
  }

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
          _buildListTile('초기화', Icons.refresh, _showResetConfirmation),
          const Divider(color: Colors.white),
          _buildListTile('앱 공유하기', Icons.share, _shareApp),
          const Divider(color: Colors.white),
          _buildListTile('리뷰 남기기', Icons.rate_review, _requestReview),
          const Divider(color: Colors.white),
          _buildListTile('개발자에게 문의하기', Icons.mail, _contactDeveloper),
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

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title:
              const Text('초기화 확인', style: TextStyle(color: AppTheme.textColor)),
          content: const Text('모든 절연 관련 기록이 삭제됩니다. 정말로 초기화하시겠습니까?',
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
                _resetApp();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetApp() async {
    await SmokeRecordManager.clearSmokeRecords();
    // 필요한 경우 다른 초기화 작업 추가
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('모든 흡연 기록이 초기화되었습니다.',
            style: TextStyle(color: AppTheme.backgroundColor)),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _shareApp() {
    Share.share('금연을 시작하세요! 이 앱을 사용해보세요: https://yourapp.com');
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
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'sangwon2618@gmail.com',
      queryParameters: {
        'subject': '금연말고절연 문의사항',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일 앱을 열 수 없습니다',
              style: TextStyle(color: AppTheme.backgroundColor)),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  void _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL을 열 수 없습니다',
              style: TextStyle(color: AppTheme.backgroundColor)),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }
}
