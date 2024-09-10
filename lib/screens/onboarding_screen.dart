import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quitSmoke/main.dart';
import 'package:quitSmoke/screens/home_screen.dart';
import 'package:quitSmoke/utils/user_preferences.dart';
import 'package:quitSmoke/theme/app_theme.dart';

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
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nicknameController,
                labelText: '닉네임',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '닉네임을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ageController,
                labelText: '나이',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '나이를 입력해주세요';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age <= 0 || age > 120) {
                    return '올바른 나이를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('성별',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _buildGenderSelector(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _smokingYearsController,
                labelText: '흡연 기간 (년)',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '흡연 기간을 입력해주세요';
                  }
                  final years = int.tryParse(value);
                  if (years == null || years < 0 || years > 100) {
                    return '올바른 흡연 기간을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _dailyCigarettesController,
                labelText: '일일 평균 흡연량',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '일일 평균 흡연량을 입력해주세요';
                  }
                  final cigarettes = int.tryParse(value);
                  if (cigarettes == null ||
                      cigarettes < 0 ||
                      cigarettes > 100) {
                    return '올바른 흡연량을 입력해주세요 (0-100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cardColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text('시작하기', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: AppTheme.cardColor,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: AppTheme.textColor),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            title: const Text(
              '남성',
              style: TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            value: '남성',
            groupValue: _gender,
            onChanged: (value) {
              setState(() {
                _gender = value!;
              });
            },
            activeColor: AppTheme.primaryColor,
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            title: const Text(
              '여성',
              style: TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            value: '여성',
            groupValue: _gender,
            onChanged: (value) {
              setState(() {
                _gender = value!;
              });
            },
            activeColor: AppTheme.primaryColor,
          ),
        ),
      ],
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
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
