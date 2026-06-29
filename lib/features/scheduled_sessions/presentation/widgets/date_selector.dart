import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  List<DateTime> get _displayDates => List.generate(
        5,
        (index) => selectedDate.add(Duration(days: index - 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _displayDates.map((date) {
          final isSelected = DateUtils.isSameDay(date, selectedDate);
          final isToday = DateUtils.isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58.w,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        transform: GradientRotation(6.6),
                        colors: [
                          Color(0xFF1F1F1F),
                          Color(0xFF333333),
                          Color(0xFF525252),
                          Color(0xFF333333),
                          Color(0xFF1F1F1F),
                        ],
                        stops: [0.0, 0.35, 0.55, 0.75, 1.0],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(
                  color: isToday && !isSelected
                      ? AppColors.primaryLiteChip
                      : const Color(0xFFF0F0F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB5B5B5).withValues(alpha: 0.15),
                    blurRadius: 1.5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? const Color(0xFFE2E2E2)
                          : const Color(0xFF7A7A7A),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    date.day.toString(),
                    style: AppTextStyles.h3.copyWith(
                      color:
                          isSelected ? Colors.white : const Color(0xFF1E1E1E),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
