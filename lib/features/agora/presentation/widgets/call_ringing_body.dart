import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

enum CallRingingMode { connecting, ringing }

/// Outbound call UI — pulsing avatar, animated status, optional footer controls.
class CallRingingBody extends StatelessWidget {
  final String sessionLabel;
  final String name;
  final String imagePath;
  final CallRingingMode mode;
  final String? statusSubtitle;
  final Widget? bottom;
  final bool showGridBackground;

  const CallRingingBody({
    super.key,
    required this.sessionLabel,
    required this.name,
    required this.imagePath,
    this.mode = CallRingingMode.ringing,
    this.statusSubtitle,
    this.bottom,
    this.showGridBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (showGridBackground) const _CallGridBackground(),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 10.h),
                Text(
                  sessionLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xff262A2D),
                    fontSize: 16.sp,
                  ),
                ),
                const Spacer(flex: 2),
                _PulsingAvatar(imagePath: imagePath),
                SizedBox(height: 20.h),
                Text(
                  name,
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0C0C1C),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                _AnimatedRingingStatus(
                  mode: mode,
                  subtitle: statusSubtitle,
                ),
                const Spacer(flex: 3),
                if (bottom != null) bottom!,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CallRingingEndButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CallRingingEndButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 82.w,
        height: 82.w,
        decoration: BoxDecoration(
          color: const Color(0xFFF52D56),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF52D56).withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: CommonImage(
            path: 'assets/image/PhoneDisconnect.png',
            height: 32.w,
            width: 32.w,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _PulsingAvatar extends StatefulWidget {
  final String imagePath;

  const _PulsingAvatar({required this.imagePath});

  @override
  State<_PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<_PulsingAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = 120.w;

    return SizedBox(
      width: avatarSize * 1.9,
      height: avatarSize * 1.9,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                _buildPulseRing(
                  avatarSize: avatarSize,
                  progress: (_controller.value + i / 3) % 1.0,
                ),
              child!,
            ],
          );
        },
        child: Container(
          width: avatarSize,
          height: avatarSize,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(avatarSize),
            child: CommonImage(path: widget.imagePath, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildPulseRing({
    required double avatarSize,
    required double progress,
  }) {
    final scale = 1.0 + (progress * 0.75);
    final opacity = (1.0 - progress).clamp(0.0, 1.0) * 0.35;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withOpacity(opacity),
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _AnimatedRingingStatus extends StatefulWidget {
  final CallRingingMode mode;
  final String? subtitle;

  const _AnimatedRingingStatus({required this.mode, this.subtitle});

  @override
  State<_AnimatedRingingStatus> createState() => _AnimatedRingingStatusState();
}

class _AnimatedRingingStatusState extends State<_AnimatedRingingStatus> {
  Timer? _timer;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      setState(() => _dotCount = (_dotCount + 1) % 4);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefix = widget.mode == CallRingingMode.connecting
        ? 'Connecting'
        : 'Ringing';
    final dots = '.' * _dotCount;
    final paddedDots = dots.padRight(3, ' ');

    return Column(
      children: [
        Text(
          '$prefix$paddedDots',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          widget.subtitle ??
              (widget.mode == CallRingingMode.connecting
                  ? 'Setting up your call'
                  : 'Waiting for healer to join'),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CallGridBackground extends StatelessWidget {
  const _CallGridBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CallGridPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _CallGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF1F5F9).withOpacity(0.5)
      ..strokeWidth = 1.0;

    const step = 35.0;

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
