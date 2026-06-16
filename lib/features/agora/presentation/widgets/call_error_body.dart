import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/widgets/common_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../utils/call_permissions.dart';

class CallErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool showOpenSettings;

  const CallErrorBody({
    super.key,
    required this.message,
    required this.onRetry,
    this.showOpenSettings = false,
  });

  bool get _suggestSettings =>
      showOpenSettings ||
      message.toLowerCase().contains('settings') ||
      message.toLowerCase().contains('blocked');

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Could not connect',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message.trim().isEmpty
                  ? 'Unable to join the call. Check your connection and try again.'
                  : message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            CommonButton(text: 'Retry', onPressed: onRetry),
            if (_suggestSettings) ...[
              SizedBox(height: 12.h),
              TextButton(
                onPressed: CallPermissions.openSettings,
                child: Text(
                  'Open Settings',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
