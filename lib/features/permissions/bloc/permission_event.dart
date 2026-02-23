import 'package:equatable/equatable.dart';

abstract class PermissionEvent extends Equatable {
  const PermissionEvent();

  @override
  List<Object> get props => [];
}

class StartPermissionFlow extends PermissionEvent {}

class RequestMicrophonePermission extends PermissionEvent {}

class RequestCameraPermission extends PermissionEvent {}

class SkipPermission extends PermissionEvent {}

class PermissionFlowCompleted extends PermissionEvent {}
