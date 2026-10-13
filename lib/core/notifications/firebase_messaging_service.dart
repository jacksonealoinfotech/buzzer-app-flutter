import 'dart:async';

// TODO: Uncomment when `firebase_messaging` package is enabled in pubspec.yaml:
// import 'package:firebase_messaging/firebase_messaging.dart';

/// Top-level background message handler for terminated/background push events.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(dynamic message) async {
  // TODO: Uncomment when `firebase_core` and `firebase_messaging` are active:
  // await Firebase.initializeApp();
  // print('Background push received: ${message.messageId}');
}

/// Service managing remote push notifications via Firebase Cloud Messaging (FCM).
class FirebaseMessagingService {
  FirebaseMessagingService();

  // TODO: Uncomment when `firebase_messaging` is active:
  // final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize({
    void Function(String? deepLink)? onMessageOpenedApp,
    void Function(String title, String body, Map<String, dynamic> data)? onForegroundMessage,
  }) async {
    // TODO: Uncomment when `firebase_messaging` is active:
    // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    //
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   final notification = message.notification;
    //   if (notification != null) {
    //     onForegroundMessage?.call(
    //       notification.title ?? '',
    //       notification.body ?? '',
    //       message.data,
    //     );
    //   }
    // });
    //
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   final deepLink = message.data['route'] as String?;
    //   onMessageOpenedApp?.call(deepLink);
    // });
  }

  Future<bool> requestPermission() async {
    // TODO: Uncomment:
    // final settings = await _fcm.requestPermission(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );
    // return settings.authorizationStatus == AuthorizationStatus.authorized;
    return false;
  }

  Future<String?> getToken() async {
    // TODO: Uncomment:
    // return _fcm.getToken();
    return null;
  }

  Future<void> subscribeToTopic(String topic) async {
    // TODO: Uncomment:
    // await _fcm.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    // TODO: Uncomment:
    // await _fcm.unsubscribeFromTopic(topic);
  }
}
