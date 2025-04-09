import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:world_bank_loan/auth/saved_login/user_session.dart';
import 'package:world_bank_loan/services/notification_navigation_service.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // This will be used to determine if we've already sent the token
  String? _currentToken;

  // API URL for saving FCM token
  final String _apiUrl = 'https://wblloanschema.com/api/save-fcm-token';

  // Navigation service for handling notification taps
  final _navigationService = NotificationNavigationService();

  Future<void> initialize() async {
    // Initialize local notifications
    await _initializeLocalNotifications();

    // Request permission for notifications
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');

      // Get FCM token
      await _getAndSendToken();

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _currentToken = newToken;
        _sendTokenToServer(newToken);
      });

      // Handle incoming messages when the app is in the foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle message when app is in background but not terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Check for initial message (app was terminated)
      _checkInitialMessage();
    } else {
      debugPrint('User declined or has not accepted notification permission');
    }
  }

  // Initialize the local notifications plugin for Android only
  Future<void> _initializeLocalNotifications() async {
    // Initialize settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize settings for Android only
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Initialize the plugin
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create the notification channel for Android
    await _createNotificationChannel();
  }

  // Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'loan_app_channel',
      'Loan App Notifications',
      description: 'Channel for loan app notifications',
      importance: Importance.high,
      enableLights: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Handle local notification tap
  void _onLocalNotificationTap(NotificationResponse response) {
    // Extract payload data
    if (response.payload != null) {
      try {
        final Map<String, dynamic> data = json.decode(response.payload!);
        _navigationService.navigateBasedOnNotification(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  // Show a local notification (Android only)
  Future<void> _showLocalNotification(
      String title, String body, Map<String, dynamic> payload) async {
    // Android specific notification details
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'loan_app_channel',
      'Loan App Notifications',
      channelDescription: 'Channel for loan app notifications',
      importance: Importance.high,
      priority: Priority.high,
      enableLights: true,
      enableVibration: true,
      color: Colors.cyan,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    // General notification details with Android only
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    // Show the notification
    await _localNotifications.show(
      DateTime.now().millisecond, // Unique ID for the notification
      title,
      body,
      notificationDetails,
      payload: json.encode(payload),
    );
  }

  // Get and send token to server
  Future<void> _getAndSendToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null && token != _currentToken) {
        _currentToken = token;
        await _sendTokenToServer(token);
      }
      print('Token: $token');
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  // Send FCM token to Laravel backend
  Future<void> _sendTokenToServer(String token) async {
    try {
      // Get auth token from user session
      final userToken = await UserSession.getToken();

      if (userToken == null) {
        debugPrint('User not logged in, cannot send FCM token to server');
        return;
      }

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': token,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('FCM token successfully sent to server');
      } else {
        debugPrint(
            'Failed to send FCM token to server. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending FCM token to server: $e');
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint('Notification Title: ${message.notification?.title}');
      debugPrint('Notification Body: ${message.notification?.body}');

      // Show a local notification
      _showLocalNotification(
        message.notification?.title ?? 'New Notification',
        message.notification?.body ?? 'You have a new notification',
        message.data,
      );
    }
  }

  // Handle messages when app is opened from a notification while in background
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('App opened from notification while in background');
    _navigateBasedOnNotification(message);
  }

  // Check if the app was opened from a notification when it was terminated
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('App opened from notification while terminated');
      _navigateBasedOnNotification(initialMessage);
    }
  }

  // Navigate to appropriate screen based on notification data
  void _navigateBasedOnNotification(RemoteMessage message) {
    final Map<String, dynamic> data = message.data;
    _navigationService.navigateBasedOnNotification(data);
  }

  // You can also add a method to manually check and update the FCM token
  // This can be called when a user logs in or the app starts
  Future<void> refreshAndUpdateToken() async {
    await _getAndSendToken();
  }

  // Method to subscribe to topics
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Method to unsubscribe from topics
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  // For debugging: Send a test notification
  Future<void> sendTestNotification() async {
    await _showLocalNotification(
      'Test Notification',
      'This is a test notification to verify everything is working correctly',
      {
        'type': 'test_notification',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
