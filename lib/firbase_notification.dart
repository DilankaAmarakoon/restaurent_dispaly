import 'package:advertising_screen/restart_app.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class NotificationServices {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize(BuildContext context) async {
    // Request notification permissions
    NotificationSettings settings = await messaging.requestPermission();

    // Log analytics instance
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    // If authorized, continue with FCM setup
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Fetch and print the FCM token
      String? token = await messaging.getToken();
      if (token != null) debugPrint("✅ FCM Token: $token");

      // Set notification presentation options when app is in foreground
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen for messages when app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        debugPrint("📩 Foreground notification: ${message.notification?.title}");
        analytics.logEvent(name: 'notification_received');
        RestartWidget.restartApp(context);
      });

      // Handle notification tap when app is in background but resumed
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        debugPrint("🔔 Notification opened from background: ${message.notification?.title}");
        analytics.logEvent(name: 'notification_opened');
      });

      // Handle notification when app is launched from a terminated state
      RemoteMessage? initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint("🚀 Notification opened from terminated state: ${initialMessage.notification?.title}");
        analytics.logEvent(name: 'notification_opened_from_terminated');
        RestartWidget.restartApp(context);
      }
    } else {
      debugPrint("⚠️ Notification permissions not granted.");
    }
  }
}
