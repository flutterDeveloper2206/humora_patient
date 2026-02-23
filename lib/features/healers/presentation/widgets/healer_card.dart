import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../common/widgets/common_image.dart';
import '../../data/healer_model.dart';
import 'healer_rating_row.dart';
import 'availability_chip.dart';

class HealerCard extends StatelessWidget {
  final HealerModel healer;
  final VoidCallback onTap;

  const HealerCard({super.key, required this.healer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Color(0xFFF9FBFC),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30.r),
                      child: CommonImage(
                        path: healer.imageUrl,
                        width: 50.w,
                        height: 50.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                healer.name,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.sp,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.textSecondary,
                                size: 20.sp,
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              CommonImage(
                                path: 'assets/image/Mask1.png',
                                width: 19.w,
                                height: 19.w,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                healer.specialization,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                width: 4.w,
                                height: 4.w,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD9D9D9),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              CommonImage(
                                path: 'assets/image/Mask.png',
                                width: 19.w,
                                height: 19.w,
                                fit: BoxFit.cover,
                              ),                          SizedBox(width: 4.w),
                              Text(
                                "${healer.experienceYears} Years",
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          HealerRatingRow(
                            rating: healer.rating,
                            reviewsCount: healer.reviewsCount,
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: const Color(0xFF16B783),
                                size: 18.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "Available Now",
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: const Color(0xFF16B783),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                width: 4.w,
                                height: 4.w,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD9D9D9),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              CommonImage(
                                path: 'assets/image/price.png',
                                width: 10.w,
                                height: 14.w,
                                fit: BoxFit.cover,
                              ),  Text(
                                " ${healer.feesPerMin}/min",
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.h,)
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Availability Days
            SizedBox(
              height: 48.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: healer.availability.length,
                separatorBuilder: (context, index) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final avail = healer.availability[index];
                  return AvailabilityChip(
                    date: avail.date,
                    isAvailable: avail.isAvailable,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
