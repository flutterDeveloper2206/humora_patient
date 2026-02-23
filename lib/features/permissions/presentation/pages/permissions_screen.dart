import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../bloc/permission_bloc.dart';
import '../../bloc/permission_event.dart';
import '../../bloc/permission_state.dart';
import '../widgets/permission_dialog.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(
        0.2,
      ), // Ensures the "black other screen" feel
      body: BlocProvider(
        create: (context) => PermissionBloc()..add(StartPermissionFlow()),
        child: BlocListener<PermissionBloc, PermissionState>(
          listener: (context, state) {
            if (state is ShowingPermissionDialog) {
              _showDialog(context, state.type);
            } else if (state is PermissionFlowFinished) {
              context.go('/healing-focus');
            }
          },
          child: Container(),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, PermissionType type) {
    final bloc = context.read<PermissionBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor:
          Colors.transparent, // We use the screen background for black effect
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 26.w),
              child: type == PermissionType.microphone
                  ? PermissionDialog(
                      title: 'Microphone Access Required',
                      description:
                          'Enable your microphone to speak with your healer during live sessions.',
                      icon: Icons.mic,
                      onConfirm: () async {
                        final status = await Permission.microphone.request();
                        if (status.isPermanentlyDenied) {
                          openAppSettings();
                        } else {
                          bloc.add(RequestMicrophonePermission());
                        }
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      },
                      onSkip: () {
                        bloc.add(SkipPermission());
                        Navigator.pop(dialogContext);
                      },
                      onClose: () {
                        bloc.add(SkipPermission());
                        Navigator.pop(dialogContext);
                      },
                    )
                  : PermissionDialog(
                      title: 'Camera Access Required',
                      description:
                          'Enable your camera to join live healing sessions and connect face-to-face with your healer.',
                      icon: Icons.camera_alt,
                      onConfirm: () async {
                        final status = await Permission.camera.request();
                        if (status.isPermanentlyDenied) {
                          openAppSettings();
                        } else {
                          bloc.add(RequestCameraPermission());
                        }
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      },
                      onSkip: () {
                        bloc.add(SkipPermission());
                        Navigator.pop(dialogContext);
                      },
                      onClose: () {
                        bloc.add(SkipPermission());
                        Navigator.pop(dialogContext);
                      },
                    ),
            ),
          ),
        );
      },
    );
  }
}
