import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Six-digit OTP field styled to match signup/login OTP screens.
class AuthOtpPinput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onCompleted;
  final bool showOuterBorder;

  const AuthOtpPinput({
    super.key,
    required this.controller,
    this.focusNode,
    this.onCompleted,
    this.showOuterBorder = false,
  });

  PinTheme _pinTheme({Color? borderColor}) {
    return PinTheme(
      width: 54.w,
      height: 54.h,
      textStyle: AppTextStyles.h2.copyWith(
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: showOuterBorder
          ? BoxDecoration(
              border: Border.all(color: borderColor ?? AppColors.border),
              borderRadius: BorderRadius.circular(12.r),
            )
          : const BoxDecoration(),
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = _pinTheme();
    final focusedTheme = _pinTheme(borderColor: AppColors.primary);

    final field = Pinput(
      length: 6,

      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      separatorBuilder: (_) => SizedBox(width: showOuterBorder ? 4.w : 4.w),
      defaultPinTheme: baseTheme,
      focusedPinTheme: showOuterBorder ? focusedTheme : baseTheme,
      submittedPinTheme: baseTheme,
      followingPinTheme: baseTheme,
      disabledPinTheme: baseTheme,
      errorPinTheme: baseTheme,
      crossAxisAlignment: CrossAxisAlignment.center,
      showCursor: true,
      cursor: Container(width: 2.w, height: 22.h, color: AppColors.primary),
      preFilledWidget: Text(
        '-',
        style: AppTextStyles.h2.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      onCompleted: onCompleted,
    );

    if (!showOuterBorder) return field;

    return Container(
      height: 54.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      // decoration: BoxDecoration(
      //   border: Border.all(color: AppColors.border),
      //   borderRadius: BorderRadius.circular(12.r),
      // ),
      child: field,
    );
  }
}
