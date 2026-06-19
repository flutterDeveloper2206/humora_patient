import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_screen.dart';

class NotificationPayload {
  final String screen;
  final Map<String, dynamic> data;
  final String title;
  final String body;

  const NotificationPayload({
    required this.screen,
    required this.data,
    required this.title,
    required this.body,
  });

  String? get bookingId {
    final value = data['bookingId'] ?? data['booking_id'] ?? data['sessionId'];
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  factory NotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final raw = message.data;
    final data = _parseDataMap(raw);
    return NotificationPayload(
      screen: NotificationScreen.normalize(
        raw['screen']?.toString() ?? data['screen']?.toString(),
      ),
      data: data,
      title: message.notification?.title ??
          raw['title']?.toString() ??
          'Humora Patient',
      body: message.notification?.body ?? raw['body']?.toString() ?? '',
    );
  }

  factory NotificationPayload.fromInbox({
    required String screen,
    required Map<String, dynamic> data,
    required String title,
    required String body,
  }) {
    return NotificationPayload(
      screen: NotificationScreen.normalize(screen),
      data: data,
      title: title,
      body: body,
    );
  }

  factory NotificationPayload.fromLocalResponse(NotificationResponse response) {
    final payload = response.payload ?? '';
    final map = <String, dynamic>{};
    var screen = NotificationScreen.home;
    var title = 'Humora Patient';
    var body = '';

    for (final part in payload.split('|')) {
      final index = part.indexOf('=');
      if (index <= 0) continue;
      final key = part.substring(0, index);
      final value = part.substring(index + 1);
      switch (key) {
        case 'screen':
          screen = NotificationScreen.normalize(value);
        case 'title':
          title = value;
        case 'body':
          body = value;
        case 'data':
          map.addAll(_parseDataMap({'data': value}));
        default:
          map[key] = value;
      }
    }

    return NotificationPayload(
      screen: screen,
      data: map,
      title: title,
      body: body,
    );
  }

  factory NotificationPayload.fromSessionReminder({
    required String screen,
    required String bookingId,
    required String message,
  }) {
    return NotificationPayload(
      screen: NotificationScreen.normalize(screen),
      data: {'bookingId': bookingId},
      title: 'Session Reminder',
      body: message,
    );
  }

  String toLocalPayload() {
    final dataJson = jsonEncode(data);
    return 'screen=$screen|title=$title|body=$body|data=$dataJson';
  }

  static Map<String, dynamic> _parseDataMap(Map<String, dynamic> raw) {
    final map = <String, dynamic>{};
    final nested = raw['data'];
    if (nested is Map<String, dynamic>) {
      map.addAll(nested);
    } else if (nested is Map) {
      map.addAll(Map<String, dynamic>.from(nested));
    } else if (nested is String && nested.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(nested);
        if (decoded is Map<String, dynamic>) {
          map.addAll(decoded);
        } else if (decoded is Map) {
          map.addAll(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {}
    }

    for (final entry in raw.entries) {
      if (entry.key == 'screen' || entry.key == 'title' || entry.key == 'body') {
        continue;
      }
      if (entry.key == 'data') continue;
      map.putIfAbsent(entry.key, () => entry.value);
    }
    return map;
  }
}
