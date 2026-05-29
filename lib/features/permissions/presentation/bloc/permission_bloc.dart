import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_event.dart';
import 'permission_state.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  PermissionBloc() : super(PermissionInitial()) {
    on<StartPermissionFlow>((event, emit) async {
      await Permission.microphone.request();
      await Permission.camera.request();
      emit(PermissionFlowFinished());
    });
  }
}
