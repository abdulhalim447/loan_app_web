import 'package:flutter/material.dart';
import 'package:world_bank_loan/core/widgets/custom_notification_overlay.dart';
import 'package:world_bank_loan/services/notification_navigation_service.dart';

/// A simplified notification service without Firebase dependency
/// This only supports local notifications triggered by the app
class NotificationService {
  // Get the navigation service
  final _navigationService = NotificationNavigationService();

  Future<void> initialize() async {
    // No initialization needed without Firebase
    debugPrint('Local notification service initialized');
  }

  // Show a local notification
  void showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) {
    // Get the navigator key from navigation service
    final navigatorKey = _navigationService.navigatorKey;

    // Only show if navigator context is available
    if (navigatorKey.currentContext != null) {
      CustomNotificationOverlay.show(
        navigatorKey.currentContext!,
        title: title,
        message: body,
        onTap: () {
          // Handle notification tap
          _navigationService.navigateBasedOnNotification(data);
        },
      );
    } else {
      debugPrint('Cannot show notification: No valid context available');
    }
  }

  // Placeholder method for compatibility with existing code
  // This used to refresh and update the Firebase token
  Future<void> refreshAndUpdateToken() async {
    debugPrint('Firebase token refresh skipped - Firebase removed');
    // No-op since Firebase is removed
  }

  // Placeholder method for compatibility with existing code
  // This used to subscribe to Firebase topics
  Future<void> subscribeToTopic(String topic) async {
    debugPrint('Topic subscription skipped - Firebase removed');
    // No-op since Firebase is removed
  }

  // Placeholder method for compatibility with existing code
  // This used to unsubscribe from Firebase topics
  Future<void> unsubscribeFromTopic(String topic) async {
    debugPrint('Topic unsubscription skipped - Firebase removed');
    // No-op since Firebase is removed
  }

  // For testing: Send a test notification
  void sendTestNotification() {
    showLocalNotification(
      title: 'Test Notification',
      body: 'This is a test notification to verify functionality',
      data: {
        'type': 'test_notification',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
