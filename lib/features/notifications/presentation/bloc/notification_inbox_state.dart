import 'package:equatable/equatable.dart';

import '../../data/models/notification_inbox_models.dart';

abstract class NotificationInboxState extends Equatable {
  const NotificationInboxState();

  @override
  List<Object?> get props => [];
}

class NotificationInboxInitial extends NotificationInboxState {}

class NotificationInboxLoading extends NotificationInboxState {}

class NotificationInboxLoaded extends NotificationInboxState {
  final List<NotificationInboxItem> items;
  final int unreadCount;
  final bool isRefreshing;

  const NotificationInboxLoaded({
    required this.items,
    required this.unreadCount,
    this.isRefreshing = false,
  });

  bool get isEmpty => items.isEmpty;

  NotificationInboxLoaded copyWith({
    List<NotificationInboxItem>? items,
    int? unreadCount,
    bool? isRefreshing,
  }) {
    return NotificationInboxLoaded(
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [items, unreadCount, isRefreshing];
}

class NotificationInboxError extends NotificationInboxState {
  final String message;

  const NotificationInboxError(this.message);

  @override
  List<Object?> get props => [message];
}
