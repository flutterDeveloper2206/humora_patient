import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../bloc/permission_bloc.dart';
import '../bloc/permission_event.dart';
import '../bloc/permission_state.dart';
import '../widgets/permission_dialog.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocProvider(
        create: (context) => PermissionBloc()..add(StartPermissionFlow()),
        child: BlocConsumer<PermissionBloc, PermissionState>(
          listenWhen: (previous, current) => current is PermissionFlowFinished,
          listener: (context, state) {
            if (state is PermissionFlowFinished) {
              context.go('/healing-focus');
            }
          },
          builder: (context, state) {
            if (state is! ShowingPermissionDialog) {
              return const SizedBox.shrink();
            }

            final isMicrophone = state.type == PermissionType.microphone;
            final baseDescription = isMicrophone
                ? 'Allow microphone access for voice calls and live counselling sessions.'
                : 'Allow camera access for video calls and live counselling sessions.';
            final deniedDescription = isMicrophone
                ? 'Microphone access was denied. Enable it in Settings to use voice calls and live counselling.'
                : 'Camera access was denied. Enable it in Settings to use video calls and live counselling.';

            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: PermissionDialog(
                  title: isMicrophone ? 'Microphone access' : 'Camera access',
                  description:
                      state.isDenied ? deniedDescription : baseDescription,
                  icon: isMicrophone
                      ? Icons.mic_outlined
                      : Icons.videocam_outlined,
                  confirmText:
                      state.isDenied ? 'Go to settings' : 'Allow access',
                  isDenied: state.isDenied,
                  onConfirm: () {
                    final bloc = context.read<PermissionBloc>();
                    if (state.isDenied) {
                      bloc.add(OpenPermissionSettings());
                      return;
                    }
                    bloc.add(
                      isMicrophone
                          ? RequestMicrophonePermission()
                          : RequestCameraPermission(),
                    );
                  },
                  onSkip: () {
                    context.read<PermissionBloc>().add(SkipPermission());
                  },
                  onClose: () {
                    context.read<PermissionBloc>().add(SkipPermission());
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
