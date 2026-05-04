import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    print("--- Notification Init Started ---");

    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // 1. Request Permission
    print("Requesting permissions...");
    final bool? granted = await androidImplementation
        ?.requestNotificationsPermission();
    print("Notification Permission Granted: $granted");

    // 2. Define the Jogging Milestone Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'jogging_milestone', // Unique ID
      'Jogging Milestones', // Visible name in Settings
      importance: Importance.max,
      description: 'Notifikasi saat mencapai jarak tertentu (10m, 100m, dst)',
      playSound: true,
      enableVibration: true,
    );

    await androidImplementation?.createNotificationChannel(channel);
    print("Notification Channel 'jogging_milestone' created.");

    // 3. Finalize Settings
    final androidSettings = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);
    print("--- Notification Init Complete ---");
  }

  // NEW: Function for immediate milestone alerts
  static Future<void> showMilestoneNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'jogging_milestone',
          'Jogging Milestones',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          // This makes the notification pop up at the top (heads-up)
          fullScreenIntent: false,
        ),
      ),
    );
  }

  static Future<void> cancel(int id) async => await _notifications.cancel(id);
}
