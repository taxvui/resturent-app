import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../firebase_options.dart';
import '../../data/repository/repository.dart' as repo;

// Top-level background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PushNotificationService.I.initNotification(isBackground: true);
  await PushNotificationService.I._showLocalNotification(message);
}

class PushNotificationModel {
  final String? title;
  final String? body;
  final String? data;
  final DateTime sentTime;

  PushNotificationModel({
    required this.title,
    required this.body,
    required this.data,
    required this.sentTime,
  });

  factory PushNotificationModel.fromMap(Map<String, dynamic> map) {
    return PushNotificationModel(
      title: map['title'],
      body: map['body'],
      data: map['data'],
      sentTime: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'data': data,
      'sentTime': sentTime.toIso8601String(),
    };
  }
}

class PushNotificationEvent extends repo.BaseApiEvent {}

class PushNotificationService {
  PushNotificationService._internal();
  static final _instance = PushNotificationService._internal();
  static PushNotificationService get I => _instance;
  String? fcmToken;

  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize Notification Service
  Future<void> initNotification({bool isBackground = false}) async {
    // 1. Request permission ONLY in foreground
    if (!isBackground) {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        print('🔕 Notification permission denied');
        return;
      }

      print('🔔 Notification permission granted');
    }

    // 2. Init local notifications (SAFE everywhere)
    await _initLocalNotifications();

    // 3. Foreground-only setup
    if (!isBackground) {
      // Get FCM token
      try {
        fcmToken = await _firebaseMessaging.getToken();
        if (fcmToken != null) {
          print("🔥 FCM Token: $fcmToken");
        }
      } catch (e) {
        print("⚠️ Could not get FCM Token: $e");
      }

      // Foreground message listener
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Register background handler ONCE
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    }
  }

  // Handle Logic for Foreground Messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (message.notification != null) {
      _showLocalNotification(message);
      _handleNotificationEvent(message);
    }
  }

  // Initialize Local Notification settings
  Future<void> _initLocalNotifications() async {
    const androidInitSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings skipped/simplified for now as per instruction
    const iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _localNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        print("Notification Tapped: ${response.payload}");
        // TODO: Handle navigation logic
      },
    );
  }

  // Show Notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotificationsPlugin.show(
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: notificationDetails,
      payload: message.data.toString(),
    );
  }

  // Handle Notification Event
  Future<void> _handleNotificationEvent(RemoteMessage message) async {
    repo.GlobalEventManager.I.fire<PushNotificationEvent>(PushNotificationEvent());
    if ((message.data['type'] as String?)?.trim().toLowerCase().contains('online') == true) {
      return repo.GlobalEventManager.I.fire<repo.KOTOrderAE>(repo.KOTOrderModifiedAE());
    }
  }
}
