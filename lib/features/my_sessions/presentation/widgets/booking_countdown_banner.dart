import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class BookingCountdownBanner extends StatefulWidget {
  final DateTime target;

  const BookingCountdownBanner({super.key, required this.target});

  @override
  State<BookingCountdownBanner> createState() => _BookingCountdownBannerState();
}

class _BookingCountdownBannerState extends State<BookingCountdownBanner> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final diff = widget.target.difference(DateTime.now());
    if (!mounted) return;
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _label {
    if (_remaining == Duration.zero) return 'Starting soon';
    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m until session';
    if (m > 0) return '${m}m ${s}s until session';
    return '${s}s until session';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryLiteChip),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, color: AppColors.primary, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              _label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
