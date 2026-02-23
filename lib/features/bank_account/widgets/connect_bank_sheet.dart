import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../common/widgets/common_image.dart';
import '../../../common/widgets/common_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ConnectBankSheet extends StatelessWidget {
  const ConnectBankSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 3.h,
                width: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              Container(
                height: 3.h,
                width: 50.w,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface1,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 20.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "Connect Your Bank\nAccounts",
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(
              fontSize: 24.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "securely connect your bank account\nto receive payouts.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 32.h),
          CommonImage(path: "assets/images/sqf.png"),
          SizedBox(height: 24.h),

          SizedBox(height: 32.h),
          Divider(color: AppColors.divider),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: CommonButton(
              text: "Confirm",
              onPressed: () {
                Navigator.pop(context, true);
              },
              borderRadius: 12.r,
            ),
          ),
        ],
      ),
    );
  }
}
