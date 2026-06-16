import 'package:auto_skeleton/auto_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/utils/common_flushbar.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../agora/presentation/models/call_phase.dart';
import '../../../agora/presentation/models/call_route_args.dart';
import '../../../agora/presentation/widgets/call_error_body.dart';
import '../../../agora/presentation/widgets/call_missing_args_screen.dart';
import '../../../live_consultation/presentation/utils/live_end_navigator.dart';
import '../../../live_consultation/presentation/bloc/live_session_cubit.dart';
import '../../../../../common/widgets/common_image.dart';
import '../bloc/voice_call_bloc.dart';
import '../bloc/voice_call_event.dart';
import '../bloc/voice_call_state.dart';

class VoiceCallScreen extends StatelessWidget {
  final CallRouteArgs? args;

  const VoiceCallScreen({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    final callArgs = args;
    if (callArgs == null) {
      return const CallMissingArgsScreen(title: 'Voice call unavailable');
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => VoiceCallBloc(args: callArgs)..add(LoadCall(callArgs)),
        ),
        if (callArgs.isLive)
          BlocProvider(
            create: (_) =>
                LiveSessionCubit()..startMonitoring(callArgs.bookingId),
          ),
      ],
      child: VoiceCallView(
        isLive: callArgs.isLive,
        bookingId: callArgs.bookingId,
      ),
    );
  }
}

class VoiceCallView extends StatelessWidget {
  final bool isLive;
  final String bookingId;

  const VoiceCallView({
    super.key,
    this.isLive = false,
    this.bookingId = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const GridBackground(),
          SafeArea(
            child: MultiBlocListener(
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
                BlocListener<VoiceCallBloc, VoiceCallState>(
                  listenWhen: (prev, curr) =>
                      curr.phase == CallPhase.ended && !isLive,
                  listener: (context, state) {
                    if (context.mounted) context.pop();
                  },
                ),
                BlocListener<VoiceCallBloc, VoiceCallState>(
                  listenWhen: (prev, curr) =>
                      isLive &&
                      curr.phase == CallPhase.ended &&
                      prev.phase != CallPhase.ended,
                  listener: (context, state) async {
                    await finishLiveSessionFromSummary(
                      context: context,
                      bookingId: bookingId,
                      summary: state.sessionSummary,
                    );
                  },
                ),
              ],
              child: BlocBuilder<VoiceCallBloc, VoiceCallState>(
                builder: (context, state) {
                  if (state.phase == CallPhase.error) {
                    return CallErrorBody(
                      message: state.errorMessage ?? 'Something went wrong',
                      onRetry: () =>
                          context.read<VoiceCallBloc>().add(RetryCall()),
                    );
                  }

                  return AutoSkeleton(
                    enabled: state.isLoading,
                    child: Column(
                      children: [
                        SizedBox(height: 10.h),
                        Text(
                          state.isLoading ? 'Connecting…' : 'Voice Call',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: const Color(0xff262A2D),
                            fontSize: 16.sp,
                          ),
                        ),
                        const Spacer(flex: 2),
                        _buildAvatar(state.callerImage),
                        SizedBox(height: 16.h),
                        Text(
                          state.callerName,
                          style: AppTextStyles.h2.copyWith(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0C0C1C),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildTimerChip(state.duration),
                        const Spacer(flex: 3),
                        if (state.phase == CallPhase.inProgress) ...[
                          Text(
                            'ACTIONS',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: const Color(0xff656565),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          _buildControlButtons(context, state),
                        ] else
                          SizedBox(height: 120.h),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String imagePath) {
    return Container(
      width: 120.w,
      height: 120.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(75.r),
        child: CommonImage(path: imagePath, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildTimerChip(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF0C0C1C)),
      ),
      child: Text(
        '$hours:$minutes:$seconds',
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 12.sp,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, VoiceCallState state) {
    return Container(
      height: 112.h,
      padding: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildCircleButton(
            icon: state.isMuted ? 'microphone-slash.png' : 'Microphone.png',
            onPressed: () => context.read<VoiceCallBloc>().add(ToggleMute()),
            backgroundColor: const Color(0xFFF5F7F9),
            iconColor: Colors.black,
            size: 58.w,
            iconSize: 24.w,
          ),
          SizedBox(width: 32.w),
          _buildCircleButton(
            icon: 'PhoneDisconnect.png',
            onPressed: () =>
                context.read<VoiceCallBloc>().add(EndCall()),
            backgroundColor: const Color(0xFFF52D56),
            iconColor: Colors.white,
            isLarge: true,
            size: 82.w,
            iconSize: 32.w,
          ),
          SizedBox(width: 32.w),
          _buildCircleButton(
            icon: 'solar_menu-dots-bold.png',
            onPressed: () {},
            backgroundColor: const Color(0xFFF5F7F9),
            iconColor: Colors.black,
            size: 58.w,
            iconSize: 24.w,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required String icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color iconColor,
    required double size,
    required double iconSize,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isLarge
                  ? const Color(0xFFF52D56).withOpacity(0.25)
                  : Colors.black.withOpacity(0.03),
              blurRadius: isLarge ? 20 : 10,
              offset: Offset(0, isLarge ? 8 : 4),
            ),
          ],
        ),
        child: Center(
          child: CommonImage(
            path: 'assets/image/$icon',
            height: iconSize,
            width: iconSize,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

class GridBackground extends StatelessWidget {
  const GridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: GridPainter(), child: Container());
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF1F5F9).withOpacity(0.5)
      ..strokeWidth = 1.0;

    const double step = 35.0;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
