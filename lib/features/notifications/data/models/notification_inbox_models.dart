import 'dart:convert';

import '../../../../core/notifications/notification_screen.dart';

class NotificationInboxItem {
  final String id;
  final String title;
  final String body;
  final String screen;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdDate;

  const NotificationInboxItem({
    required this.id,
    required this.title,
    required this.body,
    required this.screen,
    required this.data,
    required this.isRead,
    this.readAt,
    this.createdDate,
  });

  factory NotificationInboxItem.fromJson(Map<String, dynamic> json) {
    return NotificationInboxItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      screen: NotificationScreen.normalize(json['screen']?.toString()),
      data: _parseData(json['data']),
      isRead: json['isRead'] == true,
      readAt: _parseDate(json['readAt']),
      createdDate: _parseDate(json['createdDate']),
    );
  }

  NotificationInboxItem copyWith({bool? isRead, DateTime? readAt}) {
    return NotificationInboxItem(
      id: id,
      title: title,
      body: body,
      screen: screen,
      data: data,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdDate: createdDate,
    );
  }

  static List<NotificationInboxItem> placeholderList() {
    return List.generate(
      6,
      (index) => NotificationInboxItem(
        id: 'placeholder_$index',
        title: 'Booking update',
        body: 'Your session details will appear here.',
        screen: NotificationScreen.home,
        data: const {},
        isRead: index.isEven,
        createdDate: DateTime.now(),
      ),
    );
  }

  static Map<String, dynamic> _parseData(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return {};
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    try {
      return DateTime.parse(raw.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }
}

class NotificationInboxResponse {
  final int totalCount;
  final int unreadCount;
  final int page;
  final int pageSize;
  final List<NotificationInboxItem> items;

  const NotificationInboxResponse({
    required this.totalCount,
    required this.unreadCount,
    required this.page,
    required this.pageSize,
    required this.items,
  });

  factory NotificationInboxResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <NotificationInboxItem>[];
    if (rawItems is List) {
      for (final entry in rawItems) {
        if (entry is! Map<String, dynamic>) continue;
        try {
          items.add(NotificationInboxItem.fromJson(entry));
        } catch (_) {}
      }
    }
    return NotificationInboxResponse(
      totalCount: (json['totalCount'] as num?)?.toInt() ?? items.length,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      items: items,
    );
  }
}

class MarkNotificationReadResponse {
  final String message;
  final int unreadCount;

  const MarkNotificationReadResponse({
    required this.message,
    required this.unreadCount,
  });

  factory MarkNotificationReadResponse.fromJson(Map<String, dynamic> json) {
    return MarkNotificationReadResponse(
      message: json['message']?.toString() ?? '',
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}
