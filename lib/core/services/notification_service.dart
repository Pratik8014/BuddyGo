import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:buddygoapp/features/home/presentation/home_screen.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for notifications');

      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      final InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: null,
        macOS: null,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap
          _onNotificationTap(response.payload);
        },
      );

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');

      // Save token to user profile in Firestore
      await _saveTokenToFirestore(token);

      // Listen for messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received message: ${message.notification?.title}');
        _showLocalNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('App opened from notification');
        _handleNotificationClick(message.data);
      });
    }
  }

  Future<void> _saveTokenToFirestore(String? token) async {
    if (token == null) return;

    // TODO: Save token to current user's document in Firestore
    // Example: await FirebaseFirestore.instance.collection('users').doc(userId).update({'fcmToken': token});
    print('Token saved to Firestore: $token');
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'buddygo_channel',
      'BuddyGO Notifications',
      channelDescription: 'Travel updates and messages',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  void _onNotificationTap(String? payload) {
    print('Notification tapped with payload: $payload');
    // Navigate to appropriate screen based on payload
  }

  void _handleNotificationClick(Map<String, dynamic> data) {
    final type = data['type'];

    switch (type) {
      case 'new_message':
      // Navigate to chat screen
        break;
      case 'trip_update':
      // Navigate to trip details
        break;
      case 'join_request':
      // Navigate to requests screen
        break;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  Future<void> sendPushNotification({
    required String title,
    required String body,
    required String token,
    Map<String, dynamic>? data,
  }) async {
    // In production, you would send this from your backend server
    print('Sending notification to $token: $title - $body');
  }
}