import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';

class _MobileNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();
  final StreamController<String?> _payloadController = StreamController<String?>.broadcast();

  @override
  Stream<String?> get onPayloadTap => _payloadController.stream;

  @override
  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _fln.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _payloadController.add(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
    );

    await _ensureAndroidChannel();
  }

  static void _notificationTapBackground(NotificationResponse response) {}

  Future<void> _ensureAndroidChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'spill_over_tasks',
      'Spill-over Tasks',
      description: 'Notifications for spill-over tasks',
      importance: Importance.high,
    );
    final androidPlugin = _fln.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
  }

  @override
  Future<void> showSpillOverTaskNotification({required String title, required String body, required String payload}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'spill_over_tasks',
      'Spill-over Tasks',
      channelDescription: 'Notifications for spill-over tasks',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _fln.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  @override
  void dispose() {
    _payloadController.close();
  }
}

NotificationService getNotificationService() => _MobileNotificationService();


