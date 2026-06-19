import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:humora_patient/core/notifications/notification_service.dart';
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

    final granted = await NotificationService.instance.requestPermission();

    if (granted) {
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
