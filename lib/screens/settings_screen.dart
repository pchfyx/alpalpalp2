import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  double _recommendedWaterIntake = 0.0;
  final FocusNode _weightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadCurrentGoal();
  }

  @override
  void dispose() {
    _goalController.dispose();
    _weightController.dispose();
    _weightFocusNode.dispose(); // Dispose of the focus node to prevent memory leaks
    super.dispose();
  }

  Future<void> _loadCurrentGoal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int goal = prefs.getInt('dailyGoal') ?? 2000; // Default goal is 2000 ml
    _goalController.text = goal.toString();
  }

  Future<void> _saveGoal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int goal = int.parse(_goalController.text);
    await prefs.setInt('dailyGoal', goal);
    Navigator.pop(context, goal); // Return the new goal
  }

  void _resetSettings() {
    setState(() {
      _goalController.text = '2000';
      _weightController.text = '';
      _recommendedWaterIntake = 0.0;
    });
  }

  void _decreaseGoalBy100ml() {
    int currentGoal = int.tryParse(_goalController.text) ?? 2000;
    if (currentGoal > 100) {
      setState(() {
        _goalController.text = (currentGoal - 100).toString();
      });
    }
  }

  void _calculateWaterIntake() {
    double weight = double.tryParse(_weightController.text) ?? 0.0;

    // Calculation based on the reference chart
    if (weight <= 36) {
      _recommendedWaterIntake = 1.2;
    } else if (weight <= 45) {
      _recommendedWaterIntake = 1.5;
    } else if (weight <= 54) {
      _recommendedWaterIntake = 1.8;
    } else if (weight <= 64) {
      _recommendedWaterIntake = 2.1;
    } else if (weight <= 73) {
      _recommendedWaterIntake = 2.4;
    } else if (weight <= 82) {
      _recommendedWaterIntake = 2.7;
    } else if (weight <= 91) {
      _recommendedWaterIntake = 3.0;
    } else if (weight <= 100) {
      _recommendedWaterIntake = 3.3;
    } else if (weight <= 109) {
      _recommendedWaterIntake = 3.5;
    } else if (weight <= 118) {
      _recommendedWaterIntake = 3.8;
    } else if (weight <= 127) {
      _recommendedWaterIntake = 4.1;
    } else if (weight <= 136) {
      _recommendedWaterIntake = 4.4;
    } else {
      _recommendedWaterIntake = 4.7;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Set Daily Water Goal (ml)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _decreaseGoalBy100ml,
              child: const Text('-100 ml'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveGoal,
              child: const Text('Save'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetSettings,
              child: const Text('Reset'),
            ),
            const SizedBox(height: 40),
            TextField(
              focusNode: _weightFocusNode,
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter Your Weight (kg)'),
              onChanged: (value) {
                _calculateWaterIntake();
              },
              onTap: () {
                _weightFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Recommended Water Intake: ${_recommendedWaterIntake.toStringAsFixed(1)} liters',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              '* 1 liter = 1000 ml',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
