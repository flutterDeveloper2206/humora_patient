import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'notification_permission_event.dart';
import 'notification_permission_state.dart';

class NotificationPermissionBloc
    extends Bloc<NotificationPermissionEvent, NotificationPermissionState> {
  NotificationPermissionBloc() : super(const NotificationPermissionState()) {
    on<RequestNotificationPermission>(_onRequestPermission);
    on<SkipNotificationPermission>(_onSkipPermission);
  }

  Future<void> _onRequestPermission(
    RequestNotificationPermission event,
    Emitter<NotificationPermissionState> emit,
  ) async {
    emit(state.copyWith(status: NotificationPermissionStatus.loading));

    final status = await Permission.notification.request();

    if (status.isGranted) {
      emit(state.copyWith(status: NotificationPermissionStatus.granted));
    } else {
      emit(state.copyWith(status: NotificationPermissionStatus.denied));
    }
  }

  void _onSkipPermission(
    SkipNotificationPermission event,
    Emitter<NotificationPermissionState> emit,
  ) {
    emit(state.copyWith(status: NotificationPermissionStatus.skipped));
  }
}
