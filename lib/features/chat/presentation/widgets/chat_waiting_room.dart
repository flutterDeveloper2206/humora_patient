import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/chat_models.dart';

class ChatWaitingRoom extends StatelessWidget {
  final ChatAccessResponse access;
  final Duration countdown;

  const ChatWaitingRoom({
    super.key,
    required this.access,
    required this.countdown,
  });

  String get _countdownLabel {
    if (countdown <= Duration.zero) return 'Opening soon…';
    final h = countdown.inHours;
    final m = countdown.inMinutes.remainder(60);
    final s = countdown.inSeconds.remainder(60);
    if (h > 0) return 'Chat opens in ${h}h ${m}m ${s}s';
    if (m > 0) return 'Chat opens in ${m}m ${s}s';
    return 'Chat opens in ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppColors.primaryLite,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryLiteChip),
              ),
              child: Icon(
                Icons.hourglass_top_rounded,
                color: AppColors.primary,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Waiting room',
              style: AppTextStyles.h3.copyWith(
                fontSize: 18.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              access.message.isNotEmpty
                  ? access.message
                  : 'Your chat session has not started yet.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.primaryLite,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.primaryLiteChip),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_outlined, color: AppColors.primary, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    _countdownLabel,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
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
