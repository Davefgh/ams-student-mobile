import 'dart:async';
import 'notification_service.dart';

class _WebNotificationService implements NotificationService {
  final StreamController<String?> _payloadController = StreamController<String?>.broadcast();

  @override
  Stream<String?> get onPayloadTap => _payloadController.stream;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showSpillOverTaskNotification({required String title, required String body, required String payload}) async {
    // On web, fall back to SnackBar via stream so app can react similarly
    _payloadController.add(payload);
  }

  @override
  void dispose() {
    _payloadController.close();
  }
}

NotificationService getNotificationService() => _WebNotificationService();


