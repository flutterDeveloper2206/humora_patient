import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../../common/widgets/common_image.dart';
import '../bloc/video_call_bloc.dart';
import '../bloc/video_call_event.dart';
import '../bloc/video_call_state.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoCallBloc()..add(StartCall()),
      child: const VideoCallView(),
    );
  }
}

class VideoCallView extends StatelessWidget {
  const VideoCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<VideoCallBloc, VideoCallState>(
        builder: (context, state) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Background Image (Blurred for connecting, clear for connected)
              _buildBackground(state),

              // Bottom Shadow Overlay (Added as per design)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 400.h,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.6),
                      ],
                      stops: const [0.0, 0.3, 0.5, 0.8, 1.0],
                    ),
                  ),
                ),
              ),

              // UI Overlay
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    if (state.status == CallStatus.connecting) ...[
                      _buildConnectingHeader(),
                      const Spacer(),
                      _buildHealerCenterInfo(),
                      const Spacer(),
                    ] else ...[
                      _buildConnectedHeader(),
                      _buildLocalPreview(),
                      const Spacer(),
                      _buildTimer(state.duration),
                    ],
                    _buildHealerOverlayCard(),
                    SizedBox(height: 10.h),
                    _buildControlButtons(context, state),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground(VideoCallState state) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CommonImage(
          path: 'assets/image/vediocallbackground.png',
          fit: BoxFit.cover,
        ),
        if (state.status == CallStatus.connecting)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.2)),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Spacer
          // Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30.sp),
          const SizedBox(width: 40), // Placeholder
        ],
      ),
    );
  }

  Widget _buildHealerCenterInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100.r),
            child: CommonImage(
              path: 'assets/image/vediocallbackground.png',
              width: 100.w,
              height: 100.w,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'HEALER',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 10.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Dr. Helen Brook',
          style: AppTextStyles.h2.copyWith(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHealerOverlayCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 35.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30.r),
                child: CommonImage(
                  path: 'assets/image/doctorprofile.png',
                  width: 44.w,
                  height: 44.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. Helen Brooke',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 13.sp,
                      ),
                    ),
                    Text(
                      'Astrologer',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Color(0xFF3F3F3F),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  CommonImage(
                    path: 'assets/image/commonwallet.png',
                    color: AppColors.white,
                    height: 21.w,
                    width: 21.w,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '₹ 55.00',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocalPreview() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.only(top: 10.h, right: 20.w),
        child: Stack(
          children: [
            Container(
              width: 120.w,
              height: 160.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: CommonImage(
                  path: 'assets/image/shortphoto.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.refresh, color: Colors.white, size: 16.sp),
              ),
            ),
          ],
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
    /// change icon image like mute unmute mic i not change because not getting similar icon in unmuted
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCircleButton(
            icon: 'hugeicons_mic-02.png',
            onPressed: () {},
            // onPressed: () => context.read<VideoCallBloc>().add(SwitchCamera()),
          ),
          _buildCircleButton(
            icon: state.isCameraOff
                ? 'akar-icons_camera.png'
                : 'akar-icons_camera.png',
            onPressed: () => context.read<VideoCallBloc>().add(ToggleCamera()),
          ),
          _buildCircleButton(
            icon: 'hugeicons_call-02.png',
            color: AppColors.primary,
            onPressed: () {
              context.read<VideoCallBloc>().add(EndCall());
              context.pop();
            },
          ),
          _buildCircleButton(
            icon: state.isSpeakerOn
                ? 'humbleicons_volume-1.png'
                : 'humbleicons_volume-1.png',
            onPressed: () => context.read<VideoCallBloc>().add(ToggleSpeaker()),
          ),
          _buildCircleButton(
            icon: state.isMuted
                ? 'hugeicons_mic-02.png'
                : 'hugeicons_mic-02.png',
            onPressed: () => context.read<VideoCallBloc>().add(ToggleMute()),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required String icon,
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
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: CommonImage(path: 'assets/image/$icon'),
      ),
    );
  }
}
