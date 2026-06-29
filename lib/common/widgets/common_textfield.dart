import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum CommonTextFieldVariant { filled, outlined }

class CommonTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final CommonTextFieldVariant variant;
  final bool embedded;

  const CommonTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.variant = CommonTextFieldVariant.filled,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w400,
      ),
      decoration: _buildDecoration(),
    );

    if (embedded) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null && variant == CommonTextFieldVariant.filled) ...[
          Text(labelText!, style: AppTextStyles.label),
          SizedBox(height: 8.h),
        ],
        field,
      ],
    );
  }

  InputDecoration _buildDecoration() {
    final radius = BorderRadius.circular(12.r);
    final outlinedBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: AppColors.divider),
    );

    final hintStyle = AppTextStyles.bodyMedium.copyWith(
      color: AppColors.textHint,
      fontWeight: FontWeight.w400,
    );

    final labelStyle = AppTextStyles.bodySmall.copyWith(
      color: AppColors.textSecondary,
      fontSize: 11.sp,
      fontWeight: FontWeight.w400,
    );

    if (embedded) {
      return InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
      );
    }

    if (variant == CommonTextFieldVariant.outlined) {
      return InputDecoration(
        labelText: labelText,
        floatingLabelBehavior: labelText != null
            ? FloatingLabelBehavior.always
            : FloatingLabelBehavior.auto,
        labelStyle: labelStyle,
        hintText: hintText,
        hintStyle: hintStyle,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: labelText != null ? 12.h : 14.h,
        ),
        border: outlinedBorder,
        enabledBorder: outlinedBorder,
        focusedBorder: outlinedBorder,
        errorBorder: outlinedBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.error),
        ),
      );
    }

    return InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 16.h,
      ),
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.primary, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
    );
  }
}

/// Groups two [CommonTextField]s in one bordered card (finish signup name row).
class CommonGroupedTextFields extends StatelessWidget {
  final List<Widget> children;

  const CommonGroupedTextFields({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(const Divider(height: 1, color: AppColors.divider));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: items),
    );
  }
}
