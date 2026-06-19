import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/my_booking_models.dart';
import 'booking_countdown_banner.dart';

/// Group session confirmed — patient waits for healer to start via SignalR.
class GroupSessionWaitingCard extends StatelessWidget {
  final MyBookingModel booking;

  const GroupSessionWaitingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
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
                  'Group session',
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
            'Waiting for your healer to start the group session. '
            'You will be taken in automatically when it begins.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (DateTime.now().isBefore(booking.startDateTime)) ...[
            SizedBox(height: 14.h),
            BookingCountdownBanner(
              target: booking.startDateTime,
              endTime: booking.endDateTime,
            ),
          ],
        ],
      ),
    );
  }

  static MyBookingModel? findWaitingGroup(List<MyBookingModel> bookings) {
    final candidates = bookings.where((b) => b.isWaitingForGroupStart).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return candidates.isEmpty ? null : candidates.first;
  }
}
