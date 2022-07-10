// ignore_for_file: prefer_const_constructors
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future notificationDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'main_channel',
        'Main Channel',
        importance: Importance.max,
        priority: Priority.max,
      ),
    );
  }

  static Future init({bool initSchedule = false}) async {
    final android = AndroidInitializationSettings("@mipmap/ic_launcher");
    final ios = IOSInitializationSettings();

    final detail = await _notification.getNotificationAppLaunchDetails();
    if(detail != null && detail.didNotificationLaunchApp){
      onNotifications.add(detail.payload);
    }

    await _notification.initialize(
      InitializationSettings(android: android,iOS: ios),
      onSelectNotification: (payload) async {
        onNotifications.add(payload);
      },
    );
  }

  static Future showNotification(
          {int id = 0, String? title, String? body, String? payload}) async =>
      _notification.show(id, title, body, await notificationDetails(),
          payload: payload);
}
