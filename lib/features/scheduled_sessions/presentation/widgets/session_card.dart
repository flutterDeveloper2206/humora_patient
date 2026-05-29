import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/scheduled_sessions_state.dart';

class SessionCard extends StatelessWidget {
  final ScheduledSession session;
  final VoidCallback onCancel;

  const SessionCard({super.key, required this.session, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 12.w, bottom: 20.h, right: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 11.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFF1F1F1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CommonImage(
                  path: session.healerImage,
                  width: 46.w,
                  height: 46.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 8.w),
              // Details
              Expanded(
                child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.healerName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 11.sp,
                            color: const Color(0xFF1C2227),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            CommonImage(
                              path: 'assets/image/Mask1.png',
                              width: 14.w,
                              height: 14.w,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              session.category,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF282A2C),
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Icon(
                              Icons.star,
                              size: 11.sp,
                              color: const Color(0xFFFFB800),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              session.rating.toString(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF282828),
                                fontWeight: FontWeight.w500,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.sessionType,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF535353),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'Reschedule',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: const Color(0xFF3758BC),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20.w),
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
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(width: 4.w,),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: const Color(0xFF050505),
                      size: 20.sp,
                    ),
                  ],
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }
}
