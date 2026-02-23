import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_event.dart';
import 'permission_state.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  PermissionBloc() : super(PermissionInitial()) {
    on<StartPermissionFlow>((event, emit) async {
      final micStatus = await Permission.microphone.status;
      if (micStatus.isGranted) {
        add(RequestCameraPermission());
      } else {
        emit(const ShowingPermissionDialog(PermissionType.microphone));
      }
    });

    on<RequestMicrophonePermission>((event, emit) async {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        emit(const PermissionGranted(PermissionType.microphone));
        add(RequestCameraPermission());
      } else {
        emit(const PermissionDenied(PermissionType.microphone));
        add(RequestCameraPermission());
      }
    });

    on<RequestCameraPermission>((event, emit) async {
      final cameraStatus = await Permission.camera.status;
      if (cameraStatus.isGranted) {
        emit(PermissionFlowFinished());
      } else {
        emit(const ShowingPermissionDialog(PermissionType.camera));
      }
    });

    on<SkipPermission>((event, emit) {
      if (state is ShowingPermissionDialog) {
        final currentType = (state as ShowingPermissionDialog).type;
        if (currentType == PermissionType.microphone) {
          add(RequestCameraPermission());
        } else {
          emit(PermissionFlowFinished());
        }
      }
    });

    on<PermissionFlowCompleted>((event, emit) {
      emit(PermissionFlowFinished());
    });
  }
}
