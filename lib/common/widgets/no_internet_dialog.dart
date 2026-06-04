import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'common_button.dart';

class NoInternetDialog extends StatefulWidget {
  final Future<bool> Function() onRetry;

  const NoInternetDialog({super.key, required this.onRetry});

  @override
  State<NoInternetDialog> createState() => _NoInternetDialogState();
}

class _NoInternetDialogState extends State<NoInternetDialog> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    setState(() => _isRetrying = true);
    final ok = await widget.onRetry();
    if (!mounted) return;
    setState(() => _isRetrying = false);
    if (ok) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Text(
                  'No internet connection',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Divider(height: 1.h, color: AppColors.divider),
              SizedBox(height: 28.h),
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryLite,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryLiteChip.withValues(alpha: 0.6),
                  ),
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 32.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'Please check your mobile data or Wi‑Fi connection, then try again.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                    height: 1.45,
                  ),
                ),
              ),
              SizedBox(height: 28.h),
              Divider(height: 1.h, color: AppColors.divider),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
                child: CommonButton(
                  text: _isRetrying ? 'Checking...' : 'Retry',
                  isLoading: _isRetrying,
                  isDisabled: _isRetrying,
                  backgroundColor: AppColors.darkButton,
                  borderRadius: 12.r,
                  height: 52.h,
                  textStyle: AppTextStyles.button.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  onPressed: _handleRetry,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
