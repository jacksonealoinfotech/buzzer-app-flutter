import 'package:buzzer_app/core/notifications/firebase_messaging_service.dart';
import 'package:buzzer_app/core/notifications/local_notification_service.dart';
import 'package:buzzer_app/core/notifications/notification_service.dart';

/// Default facade implementation orchestrating local notifications and remote FCM push.
class DefaultNotificationService implements NotificationService {
  DefaultNotificationService({
    required LocalNotificationService localNotifications,
    required FirebaseMessagingService firebaseMessaging,
  }) : _local = localNotifications,
       _fcm = firebaseMessaging;

  final LocalNotificationService _local;
  final FirebaseMessagingService _fcm;

  @override
  Future<void> initialize() async {
    await _local.initialize();
    await _fcm.initialize(
      onForegroundMessage: (title, body, data) async {
        await _local.show(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: title,
          body: body,
          payload: data['route']?.toString(),
        );
      },
    );
  }

  @override
  Future<bool> requestPermission() async {
    final localGranted = await _local.requestPermissions();
    final fcmGranted = await _fcm.requestPermission();
    return localGranted || fcmGranted;
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) {
    return _local.show(id: id, title: title, body: body, payload: payload);
  }

  @override
  Future<void> cancelNotification(int id) => _local.cancel(id);

  @override
  Future<void> cancelAll() => _local.cancelAll();

  @override
  Future<String?> getDeviceToken() => _fcm.getToken();

  @override
  Future<void> subscribeToTopic(String topic) => _fcm.subscribeToTopic(topic);

  @override
  Future<void> unsubscribeFromTopic(String topic) =>
      _fcm.unsubscribeFromTopic(topic);
}
