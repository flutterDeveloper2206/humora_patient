import 'package:equatable/equatable.dart';

enum PermissionType { microphone, camera, completed }

abstract class PermissionState extends Equatable {
  const PermissionState();

  @override
  List<Object?> get props => [];
}

class PermissionInitial extends PermissionState {}

class ShowingPermissionDialog extends PermissionState {
  final PermissionType type;
  final bool isDenied;

  const ShowingPermissionDialog(
    this.type, {
    this.isDenied = false,
  });

  @override
  List<Object?> get props => [type, isDenied];
}

class PermissionGranted extends PermissionState {
  final PermissionType type;
  const PermissionGranted(this.type);

  @override
  List<Object?> get props => [type];
}

class PermissionDenied extends PermissionState {
  final PermissionType type;
  const PermissionDenied(this.type);

  @override
  List<Object?> get props => [type];
}

class PermissionFlowFinished extends PermissionState {}
