import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/chat_models.dart';

class ChatBookingInfoSheet {
  static Future<void> show(
    BuildContext context, {
    required ChatBookingItemDto booking,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChatBookingInfoSheet(booking: booking),
    );
  }
}

class _ChatBookingInfoSheet extends StatelessWidget {
  final ChatBookingItemDto booking;

  const _ChatBookingInfoSheet({required this.booking});

  String _money(double? value) {
    if (value == null) return '—';
    return '₹${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '—';
    return DateFormat('d MMM yyyy, h:mm a').format(value.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 22.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Session details',
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: AppColors.textHint,
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  booking.bookingReference,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.h),
                _InfoRow(label: 'Booking ID', value: booking.bookingId),
                _InfoRow(
                  label: 'Consultation type',
                  value: booking.consultationTypeLabel,
                ),
                _InfoRow(
                  label: 'Scheduled start',
                  value: _formatDate(booking.scheduledStartAt),
                ),
                _InfoRow(label: 'Status', value: booking.bookingStatus),
                _InfoRow(label: 'Duration', value: booking.formattedDuration),
                _InfoRow(
                  label: 'Billed minutes',
                  value: booking.billedMinutes?.toString() ?? '—',
                ),
                _InfoRow(
                  label: 'Free minutes applied',
                  value: booking.freeMinutesApplied?.toString() ?? '—',
                ),
                _InfoRow(
                  label: 'Price per minute',
                  value: booking.pricePerMinute > 0
                      ? _money(booking.pricePerMinute)
                      : '—',
                ),
                _InfoRow(
                  label: 'Free minutes',
                  value: booking.freeMinutes.toString(),
                ),
                _InfoRow(
                  label: 'Fixed price',
                  value: booking.fixedPrice != null
                      ? _money(booking.fixedPrice)
                      : '—',
                ),
                _InfoRow(
                  label: 'Amount charged',
                  value: _money(booking.amountCharged),
                ),
                _InfoRow(
                  label: 'Amount refunded',
                  value: _money(booking.amountRefunded),
                ),
                _InfoRow(
                  label: 'Hold amount',
                  value: _money(booking.holdAmount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
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
