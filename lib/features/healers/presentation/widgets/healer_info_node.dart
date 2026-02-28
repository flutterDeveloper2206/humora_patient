import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class HealerInfoNode extends StatelessWidget {
  final String label;
  final String? secondText;
  final String value;
  final IconData? icon;
  final bool isGlass;
  final Widget? trailing;

  const HealerInfoNode({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.secondText,
    this.isGlass = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    if (isGlass) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: _buildContent(),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if(secondText!=null)
                  Text(
                    secondText??'',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 13.sp,
                    ),
                  ),
              ],
            ),
            if (icon != null)
              Icon(
                icon,
                color: icon == Icons.star ? Colors.amber : Colors.blue,
                size: 16.sp,
              ),
            if (trailing != null) trailing!,
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textPrimary,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }
}
