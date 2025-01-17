import 'package:flutter/material.dart';
import 'package:myapp/main.dart'; // Adjust this import based on your project structure
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0); // Default time set to 8:00 AM
  int _notificationInterval = 1; // Default interval set to every hour

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
      int hour = prefs.getInt('notificationHour') ?? 8;
      int minute = prefs.getInt('notificationMinute') ?? 0;
      _notificationTime = TimeOfDay(hour: hour, minute: minute);
      _notificationInterval = prefs.getInt('notificationInterval') ?? 1; // Load the notification interval
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setInt('notificationHour', _notificationTime.hour);
    await prefs.setInt('notificationMinute', _notificationTime.minute);
    await prefs.setInt('notificationInterval', _notificationInterval); // Save the notification interval

    if (_notificationsEnabled) {
      _scheduleDailyNotifications();
    } else {
      _cancelNotifications();
    }

    Navigator.pop(context);
  }

  Future<void> _scheduleDailyNotifications() async {
    var androidDetails = const AndroidNotificationDetails(
      'channelId', 
      'channelName', 
      channelDescription: 'Description',
      importance: Importance.high,
      priority: Priority.high,
    );

    var notificationDetails = NotificationDetails(android: androidDetails);

    for (int i = 0; i < 24; i += _notificationInterval) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        i, // Notification ID
        'Time to drink water!',
        'Stay hydrated by drinking water.',
        _nextInstanceOfTime(_notificationTime.hour, _notificationTime.minute + (i * 60)),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> _cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            ListTile(
              title: Text('Notification Time: ${_notificationTime.format(context)}'),
              trailing: const Icon(Icons.edit),
              onTap: () async {
                TimeOfDay? newTime = await showTimePicker(
                  context: context,
                  initialTime: _notificationTime,
                );
                if (newTime != null) {
                  setState(() {
                    _notificationTime = newTime;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            const Text('Notification Interval:'),
            DropdownButton<int>(
              value: _notificationInterval,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Every Hour')),
                DropdownMenuItem(value: 2, child: Text('Every 2 Hours')),
                DropdownMenuItem(value: 4, child: Text('Every 4 Hours')),
                DropdownMenuItem(value: 6, child: Text('Every 6 Hours')),
              ],
              onChanged: (int? newValue) {
                setState(() {
                  _notificationInterval = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
