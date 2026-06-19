import 'dart:ui';

import 'package:auto_skeleton/auto_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/utils/common_flushbar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../agora/presentation/models/call_phase.dart';
import '../../../agora/presentation/models/call_route_args.dart';
import '../../../agora/presentation/widgets/agora_video_tile.dart';
import '../../../agora/presentation/widgets/call_error_body.dart';
import '../../../agora/presentation/widgets/call_missing_args_screen.dart';
import '../../../live_consultation/presentation/utils/live_end_navigator.dart';
import '../../../live_consultation/presentation/bloc/live_session_cubit.dart';
import '../../../../../common/widgets/common_image.dart';
import '../bloc/video_call_bloc.dart';
import '../bloc/video_call_event.dart';
import '../bloc/video_call_state.dart';

class VideoCallScreen extends StatelessWidget {
  final CallRouteArgs? args;

  const VideoCallScreen({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    final callArgs = args;
    if (callArgs == null) {
      return const CallMissingArgsScreen(title: 'Video call unavailable');
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => VideoCallBloc(args: callArgs)..add(LoadCall(callArgs)),
        ),
        if (callArgs.isLive)
          BlocProvider(
            create: (_) =>
                LiveSessionCubit()..startMonitoring(callArgs.bookingId),
          ),
      ],
      child: VideoCallView(
        isLive: callArgs.isLive,
        bookingId: callArgs.bookingId,
      ),
    );
  }
}

class VideoCallView extends StatelessWidget {
  final bool isLive;
  final String bookingId;

  const VideoCallView({
    super.key,
    this.isLive = false,
    this.bookingId = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          if (isLive) ...[
            BlocListener<LiveSessionCubit, LiveSessionState>(
              listenWhen: (prev, curr) =>
                  curr.sessionEnded != null &&
                  prev.sessionEnded != curr.sessionEnded,
              listener: (context, state) async {
                final summary = state.sessionEnded;
                if (summary == null || !context.mounted) return;
                await finishLiveSessionFromSummary(
                  context: context,
                  bookingId: bookingId,
                  summary: summary,
                  healerName: context.read<VideoCallBloc>().state.healerName,
                  healerRole: 'Healer',
                  sessionType: 'Live',
                );
              },
            ),
            BlocListener<LiveSessionCubit, LiveSessionState>(
              listenWhen: (prev, curr) =>
                  curr.lowBalanceWarning != null &&
                  prev.lowBalanceWarning != curr.lowBalanceWarning,
              listener: (context, state) {
                final warning = state.lowBalanceWarning;
                if (warning != null && context.mounted) {
                  CommonFlushbar.error(
                    context,
                    'Low wallet balance. About ${warning.estimatedMinutesLeft} minutes left.',
                  );
                }
              },
            ),
          ],
          BlocListener<VideoCallBloc, VideoCallState>(
            listenWhen: (prev, curr) =>
                curr.phase == CallPhase.ended && !isLive,
            listener: (context, state) {
              if (context.mounted) context.pop();
            },
          ),
          BlocListener<VideoCallBloc, VideoCallState>(
            listenWhen: (prev, curr) =>
                isLive &&
                curr.phase == CallPhase.ended &&
                prev.phase != CallPhase.ended,
            listener: (context, state) async {
              await finishLiveSessionFromSummary(
                context: context,
                bookingId: bookingId,
                summary: state.sessionSummary,
                healerName: state.healerName,
                healerRole: 'Healer',
                sessionType: 'Live',
              );
            },
          ),
        ],
        child: BlocBuilder<VideoCallBloc, VideoCallState>(
          builder: (context, state) {
          if (state.phase == CallPhase.error) {
            return CallErrorBody(
              message: state.errorMessage ?? 'Something went wrong',
              onRetry: () => context.read<VideoCallBloc>().add(RetryCall()),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              _buildBackground(context, state),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 400.h,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: AutoSkeleton(
                  enabled: state.isConnecting,
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      if (state.isConnecting) ...[
                        _buildConnectingHeader(),
                        const Spacer(),
                        _buildHealerCenterInfo(
                          state.healerName,
                          state.healerImage,
                        ),
                        const Spacer(),
                      ] else if (state.isInCall) ...[
                        _buildConnectedHeader(),
                        _buildLocalPreview(context, state),
                        const Spacer(),
                        _buildTimer(state.duration),
                      ] else
                        const Spacer(),
                      _buildHealerOverlayCard(
                        state.healerName,
                        state.healerImage,
                      ),
                      SizedBox(height: 10.h),
                      if (state.isInCall)
                        _buildControlButtons(context, state),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        ),
      ),
    );
  }

  Widget _buildBackground(BuildContext context, VideoCallState state) {
    if (state.isInCall && state.remoteUid != null) {
      return AgoraVideoTile(
        engine: state.engine,
        uid: state.remoteUid!,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CommonImage(
          path: state.healerImage,
          fit: BoxFit.cover,
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.45),
                ],
              ),
            ),
          ),
        ),
        if (state.isConnecting)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: ColoredBox(color: Colors.black.withOpacity(0.25)),
            ),
          ),
      ],
    );
  }

  Widget _buildConnectingHeader() {
    return Text(
      'Connecting...',
      style: AppTextStyles.h3.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildConnectedHeader() {
    return const SizedBox.shrink();
  }

  Widget _buildHealerCenterInfo(String name, String healerImage) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100.r),
          child: CommonImage(
            path: healerImage,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          name,
          style: AppTextStyles.h2.copyWith(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHealerOverlayCard(String name, String healerImage) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 35.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30.r),
            child: CommonImage(
              path: healerImage,
              width: 44.w,
              height: 44.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                Text(
                  'Healer',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalPreview(BuildContext context, VideoCallState state) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.only(top: 10.h, right: 20.w),
        child: GestureDetector(
          onTap: () => context.read<VideoCallBloc>().add(SwitchCamera()),
          child: Container(
            width: 120.w,
            height: 160.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: state.isCameraOff
                  ? ColoredBox(
                      color: Colors.black54,
                      child: Icon(Icons.videocam_off, color: Colors.white, size: 32.sp),
                    )
                  : AgoraVideoTile(
                      engine: state.engine,
                      uid: 0,
                      isLocal: true,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimer(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '$minutes:$seconds',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, VideoCallState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCircleButton(
            iconData: Icons.cameraswitch_rounded,
            onPressed: () =>
                context.read<VideoCallBloc>().add(SwitchCamera()),
          ),
          _buildCircleButton(
            icon: 'akar-icons_camera.png',
            onPressed: () =>
                context.read<VideoCallBloc>().add(ToggleCamera()),
            color: state.isCameraOff ? const Color(0xFF1E1E1E) : Colors.white54,
          ),
          _buildCircleButton(
            icon: 'hugeicons_call-02.png',
            color: AppColors.primary,
            onPressed: () => context.read<VideoCallBloc>().add(EndCall()),
          ),
          _buildCircleButton(
            icon: 'humbleicons_volume-1.png',
            onPressed: () =>
                context.read<VideoCallBloc>().add(ToggleSpeaker()),
            color: state.isSpeakerOn ? const Color(0xFF1E1E1E) : Colors.white54,
          ),
          _buildCircleButton(
            icon: state.isMuted ? 'microphone-slash.png' : 'Microphone.png',
            onPressed: () => context.read<VideoCallBloc>().add(ToggleMute()),
            color: state.isMuted ? const Color(0xFF1E1E1E) : Colors.white54,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    String? icon,
    IconData? iconData,
    required VoidCallback onPressed,
    Color color = Colors.white54,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44.w,
        height: 44.w,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: color.withOpacity(color == AppColors.primary ? 0.9 : 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: iconData != null
            ? Icon(
                iconData,
                color: Colors.white,
                size: 20.sp,
              )
            : CommonImage(path: 'assets/image/${icon ?? ''}'),
      ),
    );
  }
}
