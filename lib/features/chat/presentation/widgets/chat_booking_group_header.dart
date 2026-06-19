import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/chat_models.dart';
import 'chat_booking_info_sheet.dart';

class ChatBookingGroupHeader extends StatelessWidget {
  final ChatBookingItemDto booking;

  const ChatBookingGroupHeader({super.key, required this.booking});

  IconData get _consultationIcon {
    switch (booking.consultationType) {
      case 1:
        return Icons.phone_outlined;
      case 2:
        return Icons.videocam_outlined;
      default:
        return Icons.chat_bubble_outline;
    }
  }

  String get _scheduledLabel {
    final at = booking.scheduledStartAt;
    if (at == null) return '';
    return DateFormat('d MMM yyyy, h:mm a').format(at.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _consultationIcon,
            size: 20.sp,
            color: AppColors.primary,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.bookingReference,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_scheduledLabel.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    _scheduledLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.w),
            onPressed: () => ChatBookingInfoSheet.show(
              context,
              booking: booking,
            ),
            icon: Icon(
              Icons.info_outline,
              size: 22.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
