import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/incoming_call/incoming_call_controller.dart';
import '../../../../core/incoming_call/incoming_call_navigator.dart';
import '../../../../core/incoming_call/models/incoming_call_payload.dart';

/// Full-screen incoming call UI (Accept / Decline).
class IncomingCallScreen extends StatelessWidget {
  final IncomingCallPayload payload;

  const IncomingCallScreen({
    super.key,
    required this.payload,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: IncomingCallController.instance,
      builder: (context, _) {
        final processing = IncomingCallController.instance.isProcessing;
        return _IncomingCallBody(
          payload: payload,
          processing: processing,
        );
      },
    );
  }
}

class _IncomingCallBody extends StatelessWidget {
  final IncomingCallPayload payload;
  final bool processing;

  const _IncomingCallBody({
    required this.payload,
    required this.processing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0B12),
              Color(0xFF2D0F1F),
              Color(0xFF0C0C1C),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Column(
              children: [
                SizedBox(height: 48.h),
                Text(
                  payload.titleLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryLite,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  payload.subtitleLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white54,
                    fontSize: 12.sp,
                  ),
                ),
                const Spacer(),
                _CallerAvatar(payload: payload),
                SizedBox(height: 28.h),
                Text(
                  payload.callerName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'is calling you…',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                    fontSize: 16.sp,
                  ),
                ),
                const Spacer(),
                if (processing)
                  Padding(
                    padding: EdgeInsets.only(bottom: 32.h),
                    child: const CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                else
                  _CallActions(payload: payload),
                SizedBox(height: 48.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CallerAvatar extends StatefulWidget {
  final IncomingCallPayload payload;

  const _CallerAvatar({required this.payload});

  @override
  State<_CallerAvatar> createState() => _CallerAvatarState();
}

class _CallerAvatarState extends State<_CallerAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.payload.callerPhoto;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final scale = 1.0 + (_pulse.value * 0.08);
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35 + _pulse.value * 0.25),
                width: 2,
              ),
            ),
            child: child,
          ),
        );
      },
      child: Container(
        width: 128.w,
        height: 128.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryLite,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 32,
              spreadRadius: 4,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: photo != null && photo.isNotEmpty
            ? CommonImage(path: photo, fit: BoxFit.cover)
            : Icon(
                widget.payload.isVideo
                    ? Icons.videocam_rounded
                    : Icons.mic_rounded,
                size: 48.sp,
                color: AppColors.primary,
              ),
      ),
    );
  }
}

class _CallActions extends StatelessWidget {
  final IncomingCallPayload payload;

  const _CallActions({required this.payload});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          label: 'Decline',
          icon: Icons.call_end_rounded,
          color: const Color(0xFFE53935),
          onTap: () => IncomingCallNavigator.reject(payload),
        ),
        _ActionButton(
          label: 'Accept',
          icon: payload.isVideo
              ? Icons.videocam_rounded
              : Icons.call_rounded,
          color: const Color(0xFF2E7D32),
          onTap: () => IncomingCallNavigator.accept(payload),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          elevation: 6,
          shadowColor: color.withValues(alpha: 0.45),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 68.w,
              height: 68.w,
              child: Icon(icon, color: Colors.white, size: 30.sp),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}
