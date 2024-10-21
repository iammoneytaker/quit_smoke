import 'package:flutter/material.dart';
import 'package:quitSmoke/screens/home_screen.dart';
import 'package:quitSmoke/screens/profile_screen.dart';
import 'package:quitSmoke/screens/savings_screen.dart';
import 'package:quitSmoke/screens/statistics_screen.dart';
import 'package:quitSmoke/screens/welcome_screen.dart';
import 'package:quitSmoke/screens/onboarding_screen.dart';
import 'package:quitSmoke/theme/app_theme.dart';
import 'package:quitSmoke/utils/user_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '절연 앱',
      theme: ThemeData(
        primaryColor: AppTheme.primaryColor,
        scaffoldBackgroundColor: AppTheme.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTheme.cardColor,
          elevation: 0,
          iconTheme: IconThemeData(color: AppTheme.primaryColor),
          titleTextStyle: TextStyle(
            color: AppTheme.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: AppTheme.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: AppTheme.textColor,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: AppTheme.subtleTextColor,
            fontSize: 14,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppTheme.cardColor, // 배경색상 설정
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.subtleTextColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentColor,
            foregroundColor: AppTheme.textColor,
            textStyle: const TextStyle(fontSize: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        cardColor: AppTheme.cardColor,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      home: const InitialScreen(),
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    final userProfile = await UserPreferences.getUserProfile();
    final hasSeenWelcomeScreen = await UserPreferences.hasSeenWelcomeScreen();

    Widget nextScreen;

    if (!hasSeenWelcomeScreen) {
      nextScreen = const WelcomeScreen();
    } else if (userProfile == null) {
      nextScreen = const OnboardingScreen();
    } else {
      nextScreen = const MainScreen();
    }

    // Navigate to the determined screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child:
              CircularProgressIndicator()), // Show a loading indicator while deciding
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const HomeScreen(),
      const StatisticsScreen(),
      const SavingsScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    if (index < _widgetOptions.length) {
      // 인덱스가 리스트 범위 내인지 확인
      setState(() {
        _selectedIndex = index;
      });
    } else {
      // 예외 처리: 인덱스가 범위를 벗어났을 때
      print('Invalid index: $index');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: AppTheme.cardColor.withOpacity(1),
          primaryColor: AppTheme.primaryColor,
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: '통계',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.savings),
              label: '절약비용',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '프로필',
            ),
          ],
          currentIndex: _selectedIndex,
          backgroundColor: AppTheme.cardColor,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.subtleTextColor,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
