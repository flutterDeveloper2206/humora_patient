import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/session_join_resolver.dart';

class SessionJoinOptionTile extends StatelessWidget {
  final SessionJoinAction action;
  final VoidCallback onTap;
  final bool enabled;

  const SessionJoinOptionTile({
    super.key,
    required this.action,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Icon(
                action.icon,
                color: enabled ? AppColors.primary : AppColors.textHint,
                size: 22.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  action.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
