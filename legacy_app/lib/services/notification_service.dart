import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    String? token = await _messaging.getToken();
    if (token != null) {
      bool isSuccess = false;
      int retryCount = 0;
      const int maxRetries = 5;
      const Duration delay = Duration(seconds: 2);

      while (!isSuccess && retryCount < maxRetries) {
        isSuccess = await ApiService.sendFcmToken(token);

        if (!isSuccess) {
          retryCount++;
          await Future.delayed(delay);
        }
      }
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showNotification(
          message.notification!.title,
          message.notification!.body,
        );
      }
    });

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  static void showNotification(String? title, String? body) {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    _localNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}
