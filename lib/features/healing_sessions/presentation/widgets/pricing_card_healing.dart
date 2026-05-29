import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class PricingCardHealing extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final double price;
  final int time;
  final Function(String) onPriceChanged;
  final Function(String) onTimeChanged;

  const PricingCardHealing({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.price,
    required this.time,
    required this.onPriceChanged,
    required this.onTimeChanged,
  });

  @override
  State<PricingCardHealing> createState() => _PricingCardHealingState();
}

class _PricingCardHealingState extends State<PricingCardHealing> {
  late TextEditingController _priceController;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.price.toStringAsFixed(2),
    );
    _timeController = TextEditingController(text: "${widget.time}");
  }

  @override
  void didUpdateWidget(PricingCardHealing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.price.toStringAsFixed(2) != _priceController.text &&
        double.tryParse(_priceController.text) != widget.price) {
      _priceController.text = widget.price.toStringAsFixed(2);
    }
    if ("${widget.time}" != _timeController.text &&
        int.tryParse(_timeController.text) != widget.time) {
      _timeController.text = "${widget.time}";
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,

          colors: [
            AppColors.primaryLiteChip.withOpacity(0.002),
            Colors.white,
            Colors.white,
            AppColors.primaryLiteChip.withOpacity(0.002),
          ],
          stops: const [0.0,0.4, 0.5, 1.0],
        ),        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          CommonImage(
            path: widget.imagePath,
            width: 45.w,
            height: 35.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildChip(
                    label: "₹",
                    controller: _priceController,
                    onChanged: widget.onPriceChanged,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildChip(
                    icon: Icons.timer_outlined,
                    controller: _timeController,
                    suffix: "min",
                    onChanged: widget.onTimeChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    String? label,
    IconData? icon,
    required TextEditingController controller,
    String? suffix,
    required Function(String) onChanged,
  }) {
    return Container(
      height: 32.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.primary.withOpacity(0.02),
          ],
        ),         borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(7.r),
                bottomLeft: Radius.circular(7.r),
              ),
            ),
            alignment: Alignment.center,
            child: label != null
                ? Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  )
                : Icon(icon, size: 14.sp, color: AppColors.primary),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IntrinsicWidth(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (suffix != null) ...[
                  SizedBox(width: 2.w),
                  Text(
                    suffix,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10.sp,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
