import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class PriceInputField extends StatelessWidget {
  final String label;
  final String value;
  final bool readOnly;
  final Function(String) onChanged;

  const PriceInputField({
    super.key,
    required this.label,
    required this.value,
     this.readOnly = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          IntrinsicWidth(
            child: TextField(
              readOnly: readOnly,
              onChanged: onChanged,
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: "₹$value")
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: "₹$value".length),
                ),
              style: AppTextStyles.bodyLarge,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
