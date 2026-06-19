import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:humora_patient/core/constants/app_colors.dart';
import 'package:humora_patient/core/constants/app_text_styles.dart';
import 'package:humora_patient/features/healers/data/models/healer_model.dart';
import 'package:humora_patient/common/widgets/common_button.dart';
import 'package:humora_patient/common/widgets/common_image.dart';
import 'package:intl/intl.dart';

class HealerCarouselCard extends StatefulWidget {
  final HealerModel healer;
  final VoidCallback onTap;

  const HealerCarouselCard({
    super.key,
    required this.healer,
    required this.onTap,
  });

  @override
  State<HealerCarouselCard> createState() => _HealerCarouselCardState();
}

class _HealerCarouselCardState extends State<HealerCarouselCard> {
  late DateTime _currentWeekStart;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    // Setting to the Monday of the current week
    _currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    _selectedDate = now;
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    String monthYear = DateFormat('MMMM yyyy').format(_currentWeekStart);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/image/cardbg.png'),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Stack(
        children: [
          // Background Decorative Shine
          Positioned(
            right: -30.w,
            top: 20.h,
            child: Opacity(
              opacity: 0.15,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Doctor Image - Peeking Effect behind the glass panel but over the pink background
          Positioned(
            right: 15.w,
            top: 40.h,
            child: CommonImage(
              path: 'assets/image/detailimage.png',
              height: 220.h,
              fit: BoxFit.contain,
            ),
          ),

          // Content Layout
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildChip(widget.healer.specialization),
                        SizedBox(width: 10.w),
                        _buildChip("${widget.healer.feesPerMin}\$/Session"),
                      ],
                    ),
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.white, width: 1.5),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(5),
                      child: CommonImage(
                        path: 'assets/image/solar_heart-angle-bold-duotone.png',
                        height: 21.h,
                        width: 21.w,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  widget.healer.name,
                  style: AppTextStyles.h2.copyWith(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Hidden rating/reviews for now
                const Spacer(),
                // Glassmorphism Availability Panel
                ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 10.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Availability",
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13.sp,
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: _previousWeek,
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 6.w),
                                      child: Icon(
                                        Icons.chevron_left,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    monthYear,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _nextWeek,
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 6.w),
                                      child: Icon(
                                        Icons.chevron_right,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          _buildDayStrip(),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                // Consult Now Button
                CommonButton(
                  text: "Consult Now",
                  onPressed: widget.onTap,
                  backgroundColor: Colors.white,
                  textColor: const Color(0xFF1E1E1E),
                  borderRadius: 50.r,
                  height: 35.h,
                  textStyle: AppTextStyles.button.copyWith(
                    color: const Color(0xFF1E1E1E),
                    fontWeight: FontWeight.w500,
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

  Widget _buildChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0XFFFFDFE6), width: 1.5),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDayStrip() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final currentDate = _currentWeekStart.add(Duration(days: index));
        final dayName = DateFormat('E').format(currentDate); // "Mon", "Tue"...
        final isSelected =
            currentDate.year == _selectedDate.year &&
            currentDate.month == _selectedDate.month &&
            currentDate.day == _selectedDate.day;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = currentDate;
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: EdgeInsets.all(2.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              children: [
                Text(
                  dayName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.9),
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      currentDate.day.toString(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
