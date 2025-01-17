import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart'; // Import the splash screen
import 'screens/notification_settings_screen.dart'; // Import the notification settings screen
import 'screens/history_screen.dart'; // Import the history screen

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize time zone data
  tz.initializeTimeZones();

  // Set the default time zone to the local time zone of the device
  final String localTimeZone = tz.local.name;
  tz.setLocalLocation(tz.getLocation(localTimeZone));

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const WaterTrackerApp());
}

class WaterTrackerApp extends StatelessWidget {
  const WaterTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash', // Set the initial route to splash screen
      routes: {
        '/splash': (context) => const SplashScreen(), // Add splash screen route
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/notification_settings_screen': (context) => const NotificationSettingsScreen(), // Add notification settings route
        '/history': (context) => HistoryScreen(), // Add the history screen route
      },
    );
  }
}
