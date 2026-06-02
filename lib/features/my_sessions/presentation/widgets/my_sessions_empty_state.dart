import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/common_button.dart';
import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class MySessionsEmptyState extends StatelessWidget {
  const MySessionsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 120.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonImage(
              path: 'assets/image/stash_data-date-light.png',
              width: 72.w,
              height: 72.w,
              color: AppColors.textHint,
            ),
            SizedBox(height: 20.h),
            Text(
              'No sessions yet',
              style: AppTextStyles.h3.copyWith(
                fontSize: 18.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Book a healer from Home to see your upcoming and past sessions here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 24.h),
            CommonButton(
              text: 'Find Healers',
              onPressed: () => context.go('/home'),
              borderRadius: 12.r,
            ),
          ],
        ),
      ),
    );
  }
}
