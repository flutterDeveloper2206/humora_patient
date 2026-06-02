import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/common_button.dart';
import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class InsufficientWalletDialog extends StatelessWidget {
  final String message;
  final double? requiredAmount;
  final double? availableAmount;
  final VoidCallback onCancel;
  final VoidCallback onGoToWallet;

  const InsufficientWalletDialog({
    super.key,
    required this.message,
    this.requiredAmount,
    this.availableAmount,
    required this.onCancel,
    required this.onGoToWallet,
  });

  static Future<void> show({
    required BuildContext context,
    required String message,
    double? requiredAmount,
    double? availableAmount,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: InsufficientWalletDialog(
            message: message,
            requiredAmount: requiredAmount,
            availableAmount: availableAmount,
            onCancel: () => Navigator.of(dialogContext).pop(),
            onGoToWallet: () {
              Navigator.of(dialogContext).pop();
              if (context.mounted) {
                context.push('/wallet');
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Row(
              children: [
                GestureDetector(
                  onTap: onCancel,
                  child: Icon(
                    Icons.close,
                    color: AppColors.textPrimary,
                    size: 20.sp,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Insufficient balance',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 20.sp),
              ],
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
            child: Center(
              child: CommonImage(
                path: 'assets/image/commonwallet.png',
                width: 32.w,
                height: 32.w,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (requiredAmount != null && availableAmount != null) ...[
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Expanded(
                    child: _AmountTile(
                      label: 'Required',
                      amount: requiredAmount!,
                      accent: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _AmountTile(
                      label: 'Available',
                      amount: availableAmount!,
                      accent: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 28.h),
          Divider(height: 1.h, color: AppColors.divider),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
            child: Column(
              children: [
                CommonButton(
                  text: 'Go to Wallet',
                  backgroundColor: AppColors.darkButton,
                  borderRadius: 12.r,
                  height: 52.h,
                  textStyle: AppTextStyles.button.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  onPressed: onGoToWallet,
                ),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: onCancel,
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  final String label;
  final double amount;
  final Color accent;

  const _AmountTile({
    required this.label,
    required this.amount,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primaryLiteChip.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}
