import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _dailyGoal = 2000; // Default goal in ml
  int _currentIntake = 0;

  @override
  void initState() {
    super.initState();
    _loadDailyGoal();
    _loadIntakeHistory();
    _scheduleDailyNotifications();
  }

  Future<void> _loadDailyGoal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyGoal = prefs.getInt('dailyGoal') ?? 2000;
      _currentIntake = prefs.getInt('currentIntake') ?? 0;
    });
  }

  Future<void> _loadIntakeHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? historyData = prefs.getString('intakeHistory');
    if (historyData != null) {
      intakeHistory = Map<String, int>.from(json.decode(historyData));
    }
  }

  Future<void> _saveIntakeHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toIso8601String().substring(0, 10);
    
    // Update today's intake
    intakeHistory[today] = _currentIntake;
    prefs.setString('intakeHistory', json.encode(intakeHistory));

    // Debugging output
    print("Saved today's intake for $today: ${intakeHistory[today]} ml");
  }

  Future<void> _updateIntake(int amount) async {
    setState(() {
      _currentIntake += amount;
      if (_currentIntake < 0) {
        _currentIntake = 0; // Prevent negative intake
      }
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('currentIntake', _currentIntake);

    // Save the intake history after updating current intake
    await _saveIntakeHistory();
  }

  void _scheduleDailyNotifications() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_water_reminder',
      'Water Reminders',
      channelDescription: 'Remind to drink water',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    for (int hour in [10, 14, 18, 20]) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        hour,
        'Time to drink water!',
        'Stay hydrated by drinking a glass of water.',
        _nextInstanceOfHour(hour),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfHour(int hour) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> _navigateToSettings() async {
    final result = await Navigator.pushNamed(context, '/settings');
    if (result is int) {
      setState(() {
        _dailyGoal = result; // Update daily goal from Settings
      });
      _loadDailyGoal();
    }
  }

  Future<void> _navigateToHistory() async {
    await Navigator.pushNamed(context, '/history');
  }

  String _getMotivationalMessage() {
    if (_currentIntake >= _dailyGoal) {
      return 'YEAH! YOU DID IT! SEE YOU TOMORROW!';
    } else if (_currentIntake >= _dailyGoal * 0.75) {
      return 'MORE? LET\'S GO!';
    } else if (_currentIntake < (_dailyGoal / 4)) {
      return 'DRINK MORE!';
    } else if (_currentIntake <= 0) {
      return 'GOOD MORNING DRINK NOW!';
    } else {
      return 'DON\'T GIVE UP!';
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = _dailyGoal > 0 ? _currentIntake / _dailyGoal : 0; // Avoid division by zero

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _navigateToHistory, // Navigate to history screen
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getMotivationalMessage(), // Display motivational message
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text('Daily Goal: $_dailyGoal ml'),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
            ),
            const SizedBox(height: 20),
            Text('Current Intake: $_currentIntake ml'),
            const SizedBox(height: 20),
            // Buttons for adding intake
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _updateIntake(250),
                  child: const Text('+250 ml'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _updateIntake(500),
                  child: const Text('+500 ml'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Buttons for reducing intake
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _updateIntake(-100),
                  child: const Text('-100 ml'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _updateIntake(-50),
                  child: const Text('-50 ml'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Button to remind to drink water
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/notification_settings_screen');
              },
              child: const Text('REMIND ME TO DRINK WATER!'),
            ),
          ],
        ),
      ),
    );
  }
}

// Intake History Data
Map<String, int> intakeHistory = {};
