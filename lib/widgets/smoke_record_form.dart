import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SmokeRecordForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const SmokeRecordForm({super.key, required this.onSubmit});

  @override
  _SmokeRecordFormState createState() => _SmokeRecordFormState();
}

class _SmokeRecordFormState extends State<SmokeRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _cigaretteCountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _cigaretteCountController,
            decoration: const InputDecoration(labelText: '흡연 개수'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '흡연 개수를 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _selectDate,
                  child: Text(
                      '날짜: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: _selectTime,
                  child: Text('시간: ${_selectedTime.format(context)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('기록 추가'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final cigaretteCount = int.parse(_cigaretteCountController.text);
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      widget.onSubmit({
        'cigarette_count': cigaretteCount,
        'timestamp': dateTime.toIso8601String(),
      });

      _cigaretteCountController.clear();
      setState(() {
        _selectedDate = DateTime.now();
        _selectedTime = TimeOfDay.now();
      });
    }
  }
}
