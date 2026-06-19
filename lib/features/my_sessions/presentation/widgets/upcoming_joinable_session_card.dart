import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/widgets/common_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/my_booking_models.dart';
import 'booking_countdown_banner.dart';

/// Highlights the next joinable confirmed session (patient Scenario B equivalent).
class UpcomingJoinableSessionCard extends StatelessWidget {
  final MyBookingModel booking;
  final VoidCallback? onJoin;

  const UpcomingJoinableSessionCard({
    super.key,
    required this.booking,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryLiteChip),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryLite,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Upcoming session',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                booking.timeRangeLabel,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            booking.healerName,
            style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            booking.serviceTypeLabel,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 14.h),
          BookingCountdownBanner(
            target: booking.startDateTime,
            endTime: booking.endDateTime,
          ),
          if (onJoin != null && booking.canJoin) ...[
            SizedBox(height: 14.h),
            CommonButton(
              text: 'Join session',
              borderRadius: 12.r,
              height: 48.h,
              onPressed: onJoin!,
            ),
          ],
        ],
      ),
    );
  }

  static MyBookingModel? findNextUpcoming(List<MyBookingModel> bookings) {
    final candidates = bookings
        .where((b) => b.isUpcomingConfirmed)
        .toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return candidates.isEmpty ? null : candidates.first;
  }
}
