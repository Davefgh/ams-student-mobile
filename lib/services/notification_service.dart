import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional import: use real notifications on mobile/desktop, no-op on web.
import 'notification_service_mobile.dart'
    if (dart.library.html) 'notification_service_web.dart';

abstract class NotificationService {
  static NotificationService get instance => getNotificationService();

  Stream<String?> get onPayloadTap;

  Future<void> initialize();

  Future<void> showSpillOverTaskNotification({required String title, required String body, required String payload});

  void dispose();
}


