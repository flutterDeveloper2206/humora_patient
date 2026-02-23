import 'package:equatable/equatable.dart';

abstract class NotificationPermissionEvent extends Equatable {
  const NotificationPermissionEvent();

  @override
  List<Object?> get props => [];
}

class RequestNotificationPermission extends NotificationPermissionEvent {}

class SkipNotificationPermission extends NotificationPermissionEvent {}
