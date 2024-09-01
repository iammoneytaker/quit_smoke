import 'package:flutter/material.dart';
import 'package:quit_smoke/screens/onboarding_screen.dart';
import 'package:quit_smoke/utils/user_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _controller2 = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _controller3 = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _controller1.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _controller2.forward();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _controller3.forward();
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller1,
                builder: (context, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _controller1,
                      curve: Curves.easeOut,
                    )),
                    child: FadeTransition(
                      opacity: _controller1,
                      child: const Text(
                        "당신이 이 앱을 삭제하기 전까지",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: _controller2,
                builder: (context, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _controller2,
                      curve: Curves.easeOut,
                    )),
                    child: FadeTransition(
                      opacity: _controller2,
                      child: const Text(
                        "과정을 응원합니다. 같이 힘내봅시다.",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _controller3,
                builder: (context, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _controller3,
                      curve: Curves.easeOut,
                    )),
                    child: FadeTransition(
                      opacity: _controller3,
                      child: ElevatedButton(
                        onPressed: () {
                          UserPreferences.setAppStartDate();
                          UserPreferences
                              .setSeenWelcomeScreen(); // Mark the welcome screen as seen
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => const OnboardingScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F80ED),
                          foregroundColor: const Color(0xFFFFFFFF),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                        ),
                        child: const Text("시작하기"),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
