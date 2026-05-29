import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../../common/widgets/common_image.dart';
import '../bloc/voice_call_bloc.dart';
import '../bloc/voice_call_event.dart';
import '../bloc/voice_call_state.dart';

class VoiceCallScreen extends StatelessWidget {
  const VoiceCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VoiceCallBloc()..add(StartTimer()),
      child: const VoiceCallView(),
    );
  }
}

class VoiceCallView extends StatelessWidget {
  const VoiceCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Grid Background
          const GridBackground(),

          SafeArea(
            child: BlocBuilder<VoiceCallBloc, VoiceCallState>(
              builder: (context, state) {
                return Column(
                  children: [
                    SizedBox(height: 10.h),
                    Text(
                      'Voice Call',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xff262A2D),
                        fontSize: 16.sp,
                      ),
                    ),
                    const Spacer(flex: 2),

                    // Caller Avatar
                    _buildAvatar(state.callerImage),
                    SizedBox(height: 16.h),

                    // Caller Name
                    Text(
                      state.callerName,
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0C0C1C),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Wallet Balance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CommonImage(
                          path: 'assets/image/commonwallet.png',
                          height: 21.w,
                          width: 21.w,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '₹ ${state.walletBalance.toStringAsFixed(2)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Timer Chip
                    _buildTimerChip(state.duration),
                    const Spacer(flex: 3),

                    // Actions label
                    Text(
                      'ACTIONS',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xff656565),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Control Buttons
                    _buildControlButtons(context, state),
                  ],
                );
              },
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
            onPressed: () {
              context.read<VoiceCallBloc>().add(EndCall());
              context.pop();
            },
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
