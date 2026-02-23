import 'package:equatable/equatable.dart';

enum NotificationPermissionStatus { initial, loading, granted, denied, skipped }

class NotificationPermissionState extends Equatable {
  final NotificationPermissionStatus status;

  const NotificationPermissionState({
    this.status = NotificationPermissionStatus.initial,
  });

  NotificationPermissionState copyWith({NotificationPermissionStatus? status}) {
    return NotificationPermissionState(status: status ?? this.status);
  }

  @override
  List<Object?> get props => [status];
}
