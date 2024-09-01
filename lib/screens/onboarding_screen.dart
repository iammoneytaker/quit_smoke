import 'package:flutter/material.dart';
import 'package:quit_smoke/screens/home_screen.dart';
import 'package:quit_smoke/utils/user_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = '남성';
  final _smokingYearsController = TextEditingController();
  final _dailyCigarettesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 설정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: '닉네임',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '닉네임을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: '나이',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '나이를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('성별', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Radio<String>(
                    value: '남성',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                    activeColor: const Color(0xFF2F80ED),
                  ),
                  const Text('남성'),
                  Radio<String>(
                    value: '여성',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                    activeColor: const Color(0xFF2F80ED),
                  ),
                  const Text('여성'),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _smokingYearsController,
                decoration: const InputDecoration(
                  labelText: '흡연 기간 (년)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '흡연 기간을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dailyCigarettesController,
                decoration: const InputDecoration(
                  labelText: '일일 평균 흡연량',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '일일 평균 흡연량을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text('시작하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final userProfile = {
        'nickname': _nicknameController.text,
        'age': int.parse(_ageController.text),
        'gender': _gender,
        'smoking_years': int.parse(_smokingYearsController.text),
        'daily_cigarettes': int.parse(_dailyCigarettesController.text),
      };

      try {
        await UserPreferences.saveUserProfile(userProfile);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }
}
