import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/my_booking_models.dart';
import 'booking_status_chip.dart';

class MyBookingCard extends StatelessWidget {
  final MyBookingModel booking;
  final VoidCallback? onTap;

  const MyBookingCard({
    super.key,
    required this.booking,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
              ),
              child: Row(
                children: [
                  Text(
                    booking.bookingReference,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  BookingStatusChip(status: booking.bookingStatus),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: AppColors.primaryLiteChip,
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: const CommonImage(
                        path: 'assets/image/doctorprofile.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.healerName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLite,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            booking.serviceTypeLabel,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 15.sp,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                booking.timeRangeLabel,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 13.sp,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${booking.fixedPrice}',
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 16.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Hold ₹${booking.holdAmount}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
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
