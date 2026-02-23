import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../common/widgets/common_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class PricingCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final double price;
  final Function(String) onPriceChanged;

  const PricingCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.price,
    required this.onPriceChanged,
  });

  @override
  State<PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<PricingCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.price.toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(PricingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.price.toStringAsFixed(2) != _controller.text &&
        double.tryParse(_controller.text) != widget.price) {
      _controller.text = widget.price.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
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
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          widget.imagePath == 'assets/images/call.png'
              ? CommonImage(
                  path: widget.imagePath,
                  width: 41.w,
                  height: 43.w,
                  fit: BoxFit.cover,
                )
              : CommonImage(
                  path: widget.imagePath,
                  width: 45.w,
                  height: 35.w,
                  fit: BoxFit.cover,
                ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary.withOpacity(0.5),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          _buildPriceChip(),
        ],
      ),
    );
  }

  Widget  _buildPriceChip() {
    return Container(
      height: 30.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30.w,
            margin: EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.r),
                bottomLeft: Radius.circular(8.r),
              ),
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.07),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              "₹",
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primary.withOpacity(0.7),
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicWidth(
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: widget.onPriceChanged,
                    controller: _controller,
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.primary.withOpacity(0.8),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  "/ min",
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary.withOpacity(0.5),
                    fontSize: 12.sp,
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
