import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/widgets/common_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/live_models.dart';

class LiveSessionSummaryScreen extends StatelessWidget {
  final SessionEndedSummary summary;

  const LiveSessionSummaryScreen({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final durationMinutes = (summary.totalSeconds / 60).ceil();
    final durationLabel = durationMinutes <= 1
        ? '${summary.totalSeconds} sec'
        : '$durationMinutes min';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Session Summary',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 32.h),
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryLite,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primary,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Session ended',
                style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w600),
              ),
              if (summary.bookingReference.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  'Ref: ${summary.bookingReference}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
              SizedBox(height: 32.h),
              _SummaryCard(
                rows: [
                  _SummaryRow(label: 'Duration', value: durationLabel),
                  _SummaryRow(
                    label: 'Billed minutes',
                    value: '${summary.billedMinutes} min',
                  ),
                  if (summary.freeMinutesApplied > 0)
                    _SummaryRow(
                      label: 'Free minutes applied',
                      value: '${summary.freeMinutesApplied} min',
                    ),
                  _SummaryRow(
                    label: 'Rate',
                    value: '₹${summary.ratePerMinute.toStringAsFixed(0)}/min',
                  ),
                  _SummaryRow(
                    label: 'Total charged',
                    value: '₹${summary.totalAmountCharged.toStringAsFixed(0)}',
                    highlight: true,
                  ),
                  if (summary.endReason.isNotEmpty)
                    _SummaryRow(label: 'End reason', value: summary.endReason),
                ],
              ),
              const Spacer(),
              CommonButton(
                text: 'Done',
                backgroundColor: AppColors.darkButton,
                borderRadius: 12.r,
                height: 52.h,
                onPressed: () => context.go('/home'),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final List<_SummaryRow> rows;

  const _SummaryCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      row.value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight:
                            row.highlight ? FontWeight.w600 : FontWeight.w500,
                        color: row.highlight
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SummaryRow {
  final String label;
  final String value;
  final bool highlight;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });
}
