// TODO: Uncomment when `flutter_local_notifications` and `timezone` packages are enabled:
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

/// Service managing device-level local notifications, Android notification channels,
/// and scheduled reminders.
class LocalNotificationService {
  LocalNotificationService();

  // TODO: Uncomment when `flutter_local_notifications` is active:
  // final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize({void Function(String? payload)? onNotificationTapped}) async {
    // TODO: Uncomment when `flutter_local_notifications` is active:
    // const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    // const darwinSettings = DarwinInitializationSettings(
    //   requestAlertPermission: false,
    //   requestBadgePermission: false,
    //   requestSoundPermission: false,
    // );
    // const settings = InitializationSettings(android: androidSettings, iOS: darwinSettings, macOS: darwinSettings);
    // await _plugin.initialize(
    //   settings,
    //   onDidReceiveNotificationResponse: (response) => onNotificationTapped?.call(response.payload),
    // );
  }

  Future<bool> requestPermissions() async {
    // TODO: Uncomment when `flutter_local_notifications` is active:
    // final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    // final androidGranted = await androidPlugin?.requestNotificationsPermission() ?? false;
    // final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    // final iosGranted = await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    // return androidGranted || iosGranted;
    return false;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'default_channel',
    String channelName = 'Default Notifications',
  }) async {
    // TODO: Uncomment when `flutter_local_notifications` is active:
    // final androidDetails = AndroidNotificationDetails(
    //   channelId,
    //   channelName,
    //   importance: Importance.high,
    //   priority: Priority.high,
    // );
    // const darwinDetails = DarwinNotificationDetails(presentAlert: true, presentSound: true);
    // await _plugin.show(
    //   id,
    //   title,
    //   body,
    //   NotificationDetails(android: androidDetails, iOS: darwinDetails),
    //   payload: payload,
    // );
  }

  Future<void> cancel(int id) async {
    // TODO: Uncomment:
    // await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    // TODO: Uncomment:
    // await _plugin.cancelAll();
  }
}
