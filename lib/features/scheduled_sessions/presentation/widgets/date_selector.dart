import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_text_styles.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Special case for the design date (Wednesday 25th) if not in range
    final displayDates = [
      DateTime(2025, 9, 23),
      DateTime(2025, 9, 24),
      DateTime(2025, 9, 25),
      DateTime(2025, 9, 26),
      DateTime(2025, 9, 27),
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: displayDates.map((date) {
          final isSelected = DateUtils.isSameDay(date, selectedDate);
          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58.w,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E1E1E) : Colors.white,
                gradient: isSelected
                    ? const LinearGradient(
                  // begin: Alignment.topLeft,
                  // end: Alignment.bottomRight,
                  transform: GradientRotation(6.6),
                  colors: [
                    Color(0xFF1F1F1F), // Base Dark
                    Color(0xFF333333), // Base Dark
                    Color(0xFF525252), // Central Shine
                    Color(0xFF333333), // Base Dark
                    Color(0xFF1F1F1F), // Base Dark
                  ],
                  stops: [0.0, 0.35, 0.55, 0.75, 1.0],
                )
                    : null,
                borderRadius: BorderRadius.circular(28.r),
                // border: Border.all(
                //   color: isSelected
                //       ? const Color(0xFF1E1E1E)
                //       : const Color(0xFFF1F1F1),
                //   width: 1.w,
                // ),
                border: Border.all(color: const Color(0xFFF0F0F0)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xfFFB5B5B26).withOpacity(0.15),
                    blurRadius: 1.5,
                    spreadRadius: 0,
                    offset: const Offset(0, 0),
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
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1E1E1E),
                      fontSize: 18.sp,
                      fontWeight:FontWeight.w500,
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
