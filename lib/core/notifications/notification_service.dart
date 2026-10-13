/// Abstract facade unifying local notifications and remote push notifications.
abstract interface class NotificationService {
  /// Initializes notification services and listeners.
  Future<void> initialize();

  /// Requests user permission to show notifications.
  Future<bool> requestPermission();

  /// Displays an immediate local notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });

  /// Cancels an active or scheduled notification by [id].
  Future<void> cancelNotification(int id);

  /// Cancels all notifications.
  Future<void> cancelAll();

  /// Retrieves the current push notification device token (FCM).
  Future<String?> getDeviceToken();

  /// Subscribes to a broadcast notification topic.
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribes from a broadcast notification topic.
  Future<void> unsubscribeFromTopic(String topic);
}
