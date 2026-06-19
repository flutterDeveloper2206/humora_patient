import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../features/notifications/data/datasource/notification_api_service.dart';

/// Live + REST-backed unread notification badge for the home bell icon.
class NotificationBadgeController {
  NotificationBadgeController._();

  static final NotificationBadgeController instance =
      NotificationBadgeController._();

  final ValueNotifier<int> count = ValueNotifier<int>(0);

  final NotificationApiService _api = NotificationApiService();

  Future<void> refreshUnreadCount() async {
    try {
      final unread = await _api.getUnreadCount();
      count.value = unread;
    } catch (e) {
      developer.log(
        'Unread count fetch failed: $e',
        name: 'NotificationBadgeController',
      );
    }
  }

  void setCount(int value) {
    count.value = value < 0 ? 0 : value;
  }

  void decrement() {
    if (count.value > 0) count.value--;
  }

  void reset() {
    count.value = 0;
  }
}
