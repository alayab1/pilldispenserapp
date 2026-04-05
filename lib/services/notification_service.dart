import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // ─── INITIALIZE ───────────────────────────────────────────────────────────
  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
  }

  // ─── REQUEST PERMISSIONS ──────────────────────────────────────────────────
  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // ─── NOTIFICATION TAP HANDLER ─────────────────────────────────────────────
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  // ─── NOTIFICATION DETAILS ─────────────────────────────────────────────────
  NotificationDetails _buildNotificationDetails({
    String channelId = 'pill_reminders',
    String channelName = 'Pill Reminders',
    String channelDesc = 'Reminders to take your medication',
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: importance,
        priority: priority,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFFC4622D),
        enableVibration: true,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // ─── SHOW IMMEDIATE NOTIFICATION ──────────────────────────────────────────
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      _buildNotificationDetails(),
      payload: payload,
    );
  }

  // ─── SCHEDULE DOSE REMINDER ───────────────────────────────────────────────
  Future<void> scheduleDoseReminder({
    required int id,
    required String medicationName,
    required String dosage,
    required int compartment,
    required int hour,
    required int minute,
    int minutesBefore = 0,
  }) async {
    final scheduledTime = _nextScheduledTime(hour, minute, minutesBefore);

    await _notifications.zonedSchedule(
      id,
      '💊 Time to take your medication!',
      '$medicationName $dosage — Compartment #$compartment',
      scheduledTime,
      _buildNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'dose:$id:$compartment',
    );

    debugPrint(
        'NotificationService: scheduled $medicationName at $hour:$minute');
  }

  // ─── SCHEDULE MISSED DOSE ALERT ───────────────────────────────────────────
  Future<void> scheduleMissedDoseAlert({
    required int id,
    required String medicationName,
    required int hour,
    required int minute,
    int minutesAfter = 30,
  }) async {
    final scheduledTime = _nextScheduledTime(hour, minute, -minutesAfter);

    await _notifications.zonedSchedule(
      id + 10000,
      '⚠️ Missed dose alert',
      'You haven\'t taken $medicationName yet. Tap to mark as taken.',
      scheduledTime,
      _buildNotificationDetails(
        channelId: 'missed_doses',
        channelName: 'Missed Dose Alerts',
        channelDesc: 'Alerts for missed medications',
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'missed:$id',
    );
  }

  // ─── STREAK REMINDER ──────────────────────────────────────────────────────
  Future<void> scheduleStreakReminder({
    required int streakDays,
    int hour = 20,
    int minute = 0,
  }) async {
    final scheduledTime = _nextScheduledTime(hour, minute, 0);

    await _notifications.zonedSchedule(
      99999,
      '🔥 Keep your streak going!',
      'You\'re on a $streakDays day streak! Take your meds today to keep it up.',
      scheduledTime,
      _buildNotificationDetails(
        channelId: 'streaks',
        channelName: 'Streak Reminders',
        channelDesc: 'Daily streak motivation',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'streak',
    );
  }

  // ─── REWARD NOTIFICATION ──────────────────────────────────────────────────
  Future<void> showRewardNotification({
    required int coinsEarned,
    required String reason,
  }) async {
    await showInstantNotification(
      id: 88888,
      title: '🪙 +$coinsEarned coins earned!',
      body: reason,
      payload: 'reward',
    );
  }

  // ─── LOW PILL COUNT ALERT ─────────────────────────────────────────────────
  Future<void> showLowPillAlert({
    required String medicationName,
    required int pillsRemaining,
    required int compartment,
  }) async {
    await showInstantNotification(
      id: 77777,
      title: '⚠️ Low pill count!',
      body:
          '$medicationName is running low — only $pillsRemaining pills left in compartment #$compartment',
      payload: 'low_pills:$compartment',
    );
  }

  // ─── DISPENSER CONNECTED NOTIFICATION ────────────────────────────────────
  Future<void> showDispenserConnected(String deviceName) async {
    await showInstantNotification(
      id: 66666,
      title: '🔌 Dispenser connected!',
      body: '$deviceName is now connected and ready.',
      payload: 'dispenser_connected',
    );
  }

  // ─── CANCEL NOTIFICATIONS ─────────────────────────────────────────────────
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('NotificationService: all notifications cancelled');
  }

  Future<void> cancelMedicationNotifications(int medicationId) async {
    await _notifications.cancel(medicationId);
    await _notifications.cancel(medicationId + 10000);
  }

  // ─── GET PENDING NOTIFICATIONS ────────────────────────────────────────────
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // ─── HELPER: NEXT SCHEDULED TIME ─────────────────────────────────────────
  tz.TZDateTime _nextScheduledTime(int hour, int minute, int offsetMinutes) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    ).add(Duration(minutes: offsetMinutes));

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}