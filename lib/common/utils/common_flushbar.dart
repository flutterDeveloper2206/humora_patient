import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

enum FlushbarType { success, error, warning }

class CommonFlushbar {
  static void show(
    BuildContext context, {
    required String message,
    required FlushbarType type,
    String? title,
    Duration duration = const Duration(seconds: 3),
    FlushbarPosition position = FlushbarPosition.TOP,
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case FlushbarType.success:
        backgroundColor = Colors.green.shade800;
        icon = Icons.check_circle_outline;
        break;
      case FlushbarType.error:
        backgroundColor = AppColors.error;
        icon = Icons.error_outline;
        break;
      case FlushbarType.warning:
        backgroundColor = Colors.orange.shade800;
        icon = Icons.warning_amber_outlined;
        break;
    }

    Flushbar(
      titleText: title != null
          ? Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      messageText: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
      ),
      icon: Icon(icon, size: 28.sp, color: AppColors.white),
      duration: duration,
      backgroundColor: backgroundColor,
      flushbarPosition: position,
      margin: EdgeInsets.all(16.w),
      borderRadius: BorderRadius.circular(12.r),
      leftBarIndicatorColor: backgroundColor,
      mainButton: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          "DISMISS",
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ).show(context);
  }

  static void success(BuildContext context, String message, {String? title}) {
    show(context, message: message, type: FlushbarType.success, title: title);
  }

  static void error(BuildContext context, String message, {String? title}) {
    show(context, message: message, type: FlushbarType.error, title: title);
  }

  static void warning(BuildContext context, String message, {String? title}) {
    show(context, message: message, type: FlushbarType.warning, title: title);
  }
}
