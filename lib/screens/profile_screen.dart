import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quitSmoke/data/ad_data.dart';
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
  InterstitialAd? _supportInterstitialAd;
  InterstitialAd? _resetInterstitialAd;

  @override
  void initState() {
    super.initState();
    _loadSupportInterstitialAd();
    _loadResetInterstitialAd();
  }

  void _loadSupportInterstitialAd() {
    InterstitialAd.load(
      adUnitId: INTERSTRITIAL_ADID,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _supportInterstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Support InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void _loadResetInterstitialAd() {
    InterstitialAd.load(
      adUnitId: INTERSTRITIAL_ADID,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _resetInterstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Reset InterstitialAd failed to load: $error');
        },
      ),
    );
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
          _buildListTile('초기화', Icons.refresh, _showInitialResetConfirmation),
          const Divider(color: Colors.white),
          _buildListTile('앱 공유하기', Icons.share, _shareApp),
          const Divider(color: Colors.white),
          _buildListTile('리뷰 남기기', Icons.rate_review, _requestReview),
          const Divider(color: Colors.white),
          _buildListTile('개발자에게 문의하기', Icons.mail, _contactDeveloper),
          const Divider(color: Colors.white),
          _buildListTile(
              '광고 보고 개발자 후원하기', Icons.favorite, _showSupportConfirmation),
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

  void _showSupportConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title:
              const Text('개발자 후원', style: TextStyle(color: AppTheme.textColor)),
          content: const Text('광고를 시청하고 개발자를 후원하시겠습니까?',
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
              child: const Text('광고 시청',
                  style: TextStyle(color: AppTheme.primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
                _showSupportInterstitialAd();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSupportInterstitialAd() {
    if (_supportInterstitialAd == null) {
      print('Warning: attempt to show interstitial ad before loaded.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('광고 로딩에 실패했습니다. 다시 시도해주세요.',
              style: TextStyle(color: AppTheme.backgroundColor)),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      return;
    }
    _supportInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) => print('Ad showed.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _loadSupportInterstitialAd();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('개발자를 후원해 주셔서 감사합니다!',
                style: TextStyle(color: AppTheme.backgroundColor)),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _loadSupportInterstitialAd();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고를 불러오지 못했습니다. 다시 시도해 주세요.',
                style: TextStyle(color: AppTheme.backgroundColor)),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      },
    );

    _supportInterstitialAd!.setImmersiveMode(true);
    _supportInterstitialAd!.show();
  }

  void _showInitialResetConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title:
              const Text('초기화 확인', style: TextStyle(color: AppTheme.textColor)),
          content: const Text(
              '모든 절연 관련 기록이 삭제됩니다. 광고를 시청한 후 초기화를 진행할 수 있습니다. 계속하시겠습니까?',
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
              child: const Text('광고 시청 후 초기화',
                  style: TextStyle(color: AppTheme.primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
                _showResetInterstitialAd();
              },
            ),
          ],
        );
      },
    );
  }

  void _showResetInterstitialAd() {
    if (_resetInterstitialAd == null) {
      print('Warning: attempt to show interstitial ad before loaded.');
      _showFinalResetConfirmation();
      return;
    }
    _resetInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) => print('Ad showed.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _loadResetInterstitialAd();
        _showFinalResetConfirmation();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _loadResetInterstitialAd();
        _showFinalResetConfirmation();
      },
    );

    _resetInterstitialAd!.setImmersiveMode(true);
    _resetInterstitialAd!.show();
  }

  void _showFinalResetConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text('최종 초기화 확인',
              style: TextStyle(color: AppTheme.textColor)),
          content: const Text('정말로 모든 데이터를 초기화하시겠습니까? 이 작업은 되돌릴 수 없습니다.',
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
      path: 'contactemail@example.com',
      queryParameters: {
        'subject': '금연 앱 문의사항',
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
