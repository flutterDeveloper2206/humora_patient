import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/widgets/common_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/live_models.dart';
import '../models/live_consultation_args.dart';
import '../utils/live_request_routing.dart';
import '../utils/live_waitlist_cache.dart';

class WaitlistYourTurnDialog extends StatefulWidget {
  final WaitlistYourTurnPayload payload;
  final LiveConsultationArgs consultationArgs;
  final VoidCallback onReject;
  final VoidCallback onExpired;

  const WaitlistYourTurnDialog({
    super.key,
    required this.payload,
    required this.consultationArgs,
    required this.onReject,
    required this.onExpired,
  });

  static Future<void> show({
    required BuildContext context,
    required WaitlistYourTurnPayload payload,
    required VoidCallback onReject,
    required VoidCallback onExpired,
  }) {
    final args = LiveWaitlistCache.instance.consultationArgsForTurn(
      healerId: payload.healerId,
      consultationType: payload.consultationType,
    );
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      useRootNavigator: true,
      builder: (dialogContext) {
        return WaitlistYourTurnDialog(
          payload: payload,
          consultationArgs: args,
          onReject: onReject,
          onExpired: onExpired,
        );
      },
    );
  }

  @override
  State<WaitlistYourTurnDialog> createState() => _WaitlistYourTurnDialogState();
}

class _WaitlistYourTurnDialogState extends State<WaitlistYourTurnDialog> {
  Timer? _timer;
  int _secondsLeft = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    final expiresAt = widget.payload.expiresAt;
    if (expiresAt != null) {
      _secondsLeft = expiresAt.difference(DateTime.now()).inSeconds.clamp(0, 60);
    } else {
      _secondsLeft = 60;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        widget.onExpired();
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _onAccept() {
    _timer?.cancel();
    Navigator.of(context, rootNavigator: true).pop();
    if (!context.mounted) return;
    navigateToLiveConsultation(
      context: context,
      args: widget.consultationArgs,
    );
  }

  void _onReject() {
    _timer?.cancel();
    widget.onReject();
    Navigator.of(context, rootNavigator: true).pop();
  }

  IconData get _consultationIcon {
    switch (widget.payload.consultationType) {
      case 1:
        return Icons.phone_in_talk_rounded;
      case 2:
        return Icons.videocam_rounded;
      default:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final healerName = widget.consultationArgs.healerName;
    final typeLabel = liveConsultationTypeLabel(widget.payload.consultationType);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLite,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_consultationIcon, color: AppColors.primary),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your turn!',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '$typeLabel session with $healerName',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                children: [
                  Text(
                    'The healer is ready. Connect within',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '$_secondsLeft s',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 40.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  CommonButton(
                    text: 'Accept',
                    borderRadius: 12.r,
                    height: 52.h,
                    onPressed: _onAccept,
                  ),
                  SizedBox(height: 10.h),
                  CommonButton(
                    text: 'Reject',
                    backgroundColor: AppColors.darkButton,
                    borderRadius: 12.r,
                    height: 52.h,
                    onPressed: _onReject,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
