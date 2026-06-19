import 'package:equatable/equatable.dart';

abstract class NotificationInboxEvent extends Equatable {
  const NotificationInboxEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationInbox extends NotificationInboxEvent {
  const LoadNotificationInbox();
}

class RefreshNotificationInbox extends NotificationInboxEvent {
  const RefreshNotificationInbox();
}

class MarkNotificationRead extends NotificationInboxEvent {
  final String id;

  const MarkNotificationRead(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkAllNotificationsRead extends NotificationInboxEvent {
  const MarkAllNotificationsRead();
}

class DeleteNotification extends NotificationInboxEvent {
  final String id;

  const DeleteNotification(this.id);

  @override
  List<Object?> get props => [id];
}

class OpenNotificationItem extends NotificationInboxEvent {
  final String id;

  const OpenNotificationItem(this.id);

  @override
  List<Object?> get props => [id];
}
