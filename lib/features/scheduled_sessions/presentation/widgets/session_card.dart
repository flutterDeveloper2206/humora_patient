import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/scheduled_sessions_state.dart';

class SessionCard extends StatelessWidget {
  final ScheduledSession session;
  final VoidCallback onCancel;
  final VoidCallback? onTap;

  const SessionCard({
    super.key,
    required this.session,
    required this.onCancel,
    this.onTap,
  });

  Color get _statusColor {
    switch (session.bookingStatus) {
      case 2:
        return AppColors.primary;
      case 3:
        return const Color(0xFF3758BC);
      case 4:
        return AppColors.textSecondary;
      case 5:
      case 7:
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: 12.w, right: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: const Color(0xFFF1F1F1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CommonImage(
                path: session.healerImage,
                width: 46.w,
                height: 46.w,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.healerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                            color: const Color(0xFF1C2227),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          session.bookingStatusLabel,
                          style: AppTextStyles.caption.copyWith(
                            color: _statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    session.serviceTypeLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (session.sessionTypeLabel != session.serviceTypeLabel) ...[
                    SizedBox(height: 4.h),
                    Text(
                      session.sessionTypeLabel,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF282A2C),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                  if (session.bookingReference.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      session.bookingReference,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      if (session.durationLabel != null) ...[
                        Icon(
                          Icons.schedule,
                          size: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          session.durationLabel!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],
                      if (session.priceLabel != null)
                        Text(
                          session.priceLabel!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                          ),
                        ),
                      if (session.isLiveDirect) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLite,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: AppColors.primaryLiteChip),
                          ),
                          child: Text(
                            'Live',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 9.sp,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (session.canCancel) ...[
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: onCancel,
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: const Color(0xFF535353),
                          fontWeight: FontWeight.w500,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color(0xFF050505),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
