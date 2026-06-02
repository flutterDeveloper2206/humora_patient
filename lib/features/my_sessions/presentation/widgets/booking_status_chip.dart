import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/my_booking_models.dart';

class BookingStatusChip extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: colors.text,
        ),
      ),
    );
  }

  _StatusColors _colorsFor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
      case BookingStatus.active:
        return _StatusColors(
          AppColors.primaryLite,
          AppColors.primaryLiteChip,
          AppColors.primary,
        );
      case BookingStatus.completed:
        return _StatusColors(
          const Color(0xFFE8F8EF),
          const Color(0xFFB8E6C8),
          const Color(0xFF2E7D4F),
        );
      case BookingStatus.pending:
        return _StatusColors(
          const Color(0xFFFFF8E6),
          const Color(0xFFFFE4A8),
          const Color(0xFFB8860B),
        );
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
      case BookingStatus.expired:
      case BookingStatus.noShow:
      case BookingStatus.autoDisconnected:
        return _StatusColors(
          const Color(0xFFF5F5F5),
          AppColors.divider,
          AppColors.textSecondary,
        );
      case BookingStatus.unknown:
        return _StatusColors(
          AppColors.surface,
          AppColors.divider,
          AppColors.textHint,
        );
    }
  }
}

class _StatusColors {
  final Color background;
  final Color border;
  final Color text;

  _StatusColors(this.background, this.border, this.text);
}
