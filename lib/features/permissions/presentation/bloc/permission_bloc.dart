import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_event.dart';
import 'permission_state.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  PermissionBloc() : super(PermissionInitial()) {
    on<StartPermissionFlow>(_onStart);
    on<RequestMicrophonePermission>(_onRequestMicrophone);
    on<RequestCameraPermission>(_onRequestCamera);
    on<OpenPermissionSettings>(_onOpenSettings);
    on<SkipPermission>(_onSkip);
  }

  void _onStart(StartPermissionFlow event, Emitter<PermissionState> emit) {
    emit(const ShowingPermissionDialog(PermissionType.microphone));
  }

  Future<void> _onRequestMicrophone(
    RequestMicrophonePermission event,
    Emitter<PermissionState> emit,
  ) async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      emit(const ShowingPermissionDialog(PermissionType.camera));
      return;
    }
    emit(
      const ShowingPermissionDialog(
        PermissionType.microphone,
        isDenied: true,
      ),
    );
  }

  Future<void> _onRequestCamera(
    RequestCameraPermission event,
    Emitter<PermissionState> emit,
  ) async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      emit(PermissionFlowFinished());
      return;
    }
    emit(
      const ShowingPermissionDialog(
        PermissionType.camera,
        isDenied: true,
      ),
    );
  }

  Future<void> _onOpenSettings(
    OpenPermissionSettings event,
    Emitter<PermissionState> emit,
  ) async {
    final current = state;
    if (current is! ShowingPermissionDialog || !current.isDenied) return;

    await openAppSettings();
    final permission = _permissionFor(current.type);
    final status = await permission.status;
    if (status.isGranted) {
      _advanceAfterGrant(emit, current.type);
      return;
    }

    emit(ShowingPermissionDialog(current.type, isDenied: true));
  }

  void _onSkip(SkipPermission event, Emitter<PermissionState> emit) {
    final current = state;
    if (current is! ShowingPermissionDialog) return;

    if (current.type == PermissionType.microphone) {
      emit(const ShowingPermissionDialog(PermissionType.camera));
      return;
    }
    emit(PermissionFlowFinished());
  }

  void _advanceAfterGrant(Emitter<PermissionState> emit, PermissionType type) {
    if (type == PermissionType.microphone) {
      emit(const ShowingPermissionDialog(PermissionType.camera));
      return;
    }
    emit(PermissionFlowFinished());
  }

  Permission _permissionFor(PermissionType type) {
    switch (type) {
      case PermissionType.microphone:
        return Permission.microphone;
      case PermissionType.camera:
        return Permission.camera;
      case PermissionType.completed:
        return Permission.microphone;
    }
  }
}
