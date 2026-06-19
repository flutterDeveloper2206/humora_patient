import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/widgets/common_button.dart';
import '../../../../common/widgets/common_textfield.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class CancelBookingDialog extends StatefulWidget {
  final VoidCallback onDismiss;
  final ValueChanged<String> onConfirm;

  const CancelBookingDialog({
    super.key,
    required this.onDismiss,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required ValueChanged<String> onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: CancelBookingDialog(
            onDismiss: () => Navigator.of(dialogContext).pop(),
            onConfirm: (reason) {
              Navigator.of(dialogContext).pop();
              onConfirm(reason);
            },
          ),
        );
      },
    );
  }

  @override
  State<CancelBookingDialog> createState() => _CancelBookingDialogState();
}

class _CancelBookingDialogState extends State<CancelBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onConfirm(_reasonController.text.trim());
    }
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
                  onTap: widget.onDismiss,
                  child: Icon(
                    Icons.close,
                    color: AppColors.textPrimary,
                    size: 20.sp,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Cancel booking',
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
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
            child: Text(
              'Please tell us why you want to cancel. Your wallet hold will be released immediately.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                height: 1.45,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
            child: Form(
              key: _formKey,
              child: CommonTextField(
                controller: _reasonController,
                labelText: 'Reason',
                hintText: 'e.g. Changed my schedule',
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a reason';
                  }
                  return null;
                },
              ),
            ),
          ),
          SizedBox(height: 28.h),
          Divider(height: 1.h, color: AppColors.divider),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
            child: Column(
              children: [
                CommonButton(
                  text: 'Confirm cancellation',
                  backgroundColor: AppColors.darkButton,
                  borderRadius: 12.r,
                  height: 52.h,
                  textStyle: AppTextStyles.button.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  onPressed: _submit,
                ),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: Text(
                    'Keep booking',
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
