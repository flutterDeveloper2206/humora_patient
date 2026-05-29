import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class SessionTimelineItem extends StatelessWidget {
  final String title;
  final List<String> slots;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onAdd;
  final Function(int)? onRemove;

  const SessionTimelineItem({
    super.key,
    required this.title,
    required this.slots,
    this.isFirst = false,
    this.isLast = false,
    this.onAdd,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: slots.isEmpty
                      ? AppColors.white
                      : AppColors.textPrimary,
                  border: Border.all(color: AppColors.divider, width: 1),
                ),
                child: slots.isNotEmpty
                    ? Center(
                        child: Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 1.w, color: AppColors.divider),
                ),
            ],
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 34.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: slots.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: _buildSlotChip(index, slots[index]),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        height: 30.h,
                        width: 30.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            size: 18.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isLast) SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotChip(int index, String time) {
    return GestureDetector(
      onLongPress: () => onRemove?.call(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFF232323),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => onRemove?.call(index),
              child: Icon(
                Icons.close,
                size: 14.sp,
                color: AppColors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
