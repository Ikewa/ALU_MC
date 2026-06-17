import 'dart:typed_data'; // Needed for Int64List
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 1. Initialize the plugin
    await _notificationsPlugin.initialize(settings: settings);

    // 2. NEW: REQUEST PERMISSION (Crucial for Android 13+)
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  // --- 1. SCHEDULE SPECIFIC PRAYER ALARM ---
  static Future<void> schedulePrayer(
    DateTime scheduledTime,
    String prayerName,
    int id,
  ) async {
    final kigaliLocation = tz.getLocation('Africa/Kigali');

    final tz.TZDateTime now = tz.TZDateTime.now(kigaliLocation);
    tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
      scheduledTime,
      kigaliLocation,
    );

    if (tzScheduledTime.isBefore(now)) {
      return;
    }

    final Int64List vibrationPattern = Int64List.fromList([
      0,
      1000,
      500,
      1000,
      500,
      1000,
      500,
      1000,
    ]);

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: 'Time for $prayerName',
      body: 'Hayya \'ala-s-Salah (Come to prayer)',
      scheduledDate: tzScheduledTime,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_alarm_channel',
          'Prayer Alarms',
          channelDescription: 'Loud alarms for prayer times',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('alarm_sound'),
          enableVibration: true,
          vibrationPattern: vibrationPattern,
          fullScreenIntent: true,
          timeoutAfter: 30000,
        ),
        iOS: const DarwinNotificationDetails(sound: 'alarm_sound.caf'),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  // --- 2. SCHEDULE DAILY 10 AM NOTIFICATION ---
  static Future<void> scheduleDailyTenAM() async {
    final kigaliLocation = tz.getLocation('Africa/Kigali');
    final now = tz.TZDateTime.now(kigaliLocation);

    var scheduledDate = tz.TZDateTime(
      kigaliLocation,
      now.year,
      now.month,
      now.day,
      10,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id: 888,
      title: 'Daily Inspiration',
      body: 'Tap to read today\'s Hadith...',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_hadith_channel',
          'Daily Hadith',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // --- 3. FRIDAY REMINDER ---
  static Future<void> scheduleFridayMeeting() async {
    final kigaliLocation = tz.getLocation('Africa/Kigali');
    final now = tz.TZDateTime.now(kigaliLocation);

    var scheduledDate = tz.TZDateTime(
      kigaliLocation,
      now.year,
      now.month,
      now.day,
      8,
      0,
    );

    int daysUntilFriday = (DateTime.friday - now.weekday) % 7;
    if (daysUntilFriday == 0 && scheduledDate.isBefore(now)) {
      daysUntilFriday = 7;
    }
    scheduledDate = scheduledDate.add(Duration(days: daysUntilFriday));

    await _notificationsPlugin.zonedSchedule(
      id: 777,
      title: 'Friday Reminder',
      body: 'Don\'t forget to read Surah Al-Kahf today!',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'friday_reminder_channel',
          'Friday Reminders',
          channelDescription: 'Weekly Friday reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // --- 4. EVENT ALARM (1 Hour Before) ---
  static Future<void> scheduleEvent(
    int id,
    String title,
    DateTime eventDate,
  ) async {
    final kigaliLocation = tz.getLocation('Africa/Kigali');

    final tzEventDate = tz.TZDateTime.from(eventDate, kigaliLocation);
    final notificationTime = tzEventDate.subtract(const Duration(hours: 1));

    if (notificationTime.isAfter(tz.TZDateTime.now(kigaliLocation))) {
      await _notificationsPlugin.zonedSchedule(
        id: 1000 + id,
        title: 'Upcoming: $title',
        body: 'Starting in 1 hour!',
        scheduledDate: notificationTime,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'event_reminder_channel',
            'Event Reminders',
            channelDescription: 'Reminders for upcoming events',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
