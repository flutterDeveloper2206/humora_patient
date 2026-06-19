import 'package:auto_skeleton/auto_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../common/utils/common_flushbar.dart';
import '../../../../common/utils/safe_navigation.dart';
import '../../../../common/widgets/common_button.dart';
import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/my_booking_models.dart';
import '../bloc/my_session_detail_bloc.dart';
import '../bloc/my_session_detail_event.dart';
import '../bloc/my_session_detail_state.dart';
import '../utils/my_sessions_loading.dart';
import '../utils/session_join_navigator.dart';
import '../widgets/booking_countdown_banner.dart';
import '../widgets/booking_status_chip.dart';
import '../widgets/cancel_booking_dialog.dart';
import '../widgets/group_session_waiting_card.dart';
import '../widgets/session_join_option_tile.dart';
import '../../domain/session_join_resolver.dart';

class MySessionDetailScreen extends StatelessWidget {
  final String bookingId;

  const MySessionDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MySessionDetailBloc()..add(LoadBookingDetail(bookingId)),
      child: MySessionDetailView(bookingId: bookingId),
    );
  }
}

class MySessionDetailView extends StatelessWidget {
  final String bookingId;

  const MySessionDetailView({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: AppColors.textPrimary, size: 28.sp),
          onPressed: () => safePop(context, fallbackLocation: '/my-sessions'),
        ),
        title: BlocBuilder<MySessionDetailBloc, MySessionDetailState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session Details',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                  ),
                ),
                if (state.isBusy)
                  Text(
                    'Loading...',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      body: BlocConsumer<MySessionDetailBloc, MySessionDetailState>(
        listenWhen: (prev, curr) {
          if (curr is MySessionDetailError) {
            if (prev is MySessionDetailLoaded && prev.isRefreshing) {
              return false;
            }
            return true;
          }
          if (curr is MySessionDetailLoaded) {
            if (curr.successMessage != null &&
                (prev is! MySessionDetailLoaded ||
                    prev.successMessage != curr.successMessage)) {
              return true;
            }
            if (curr.cancelError != null &&
                (prev is! MySessionDetailLoaded ||
                    prev.cancelError != curr.cancelError)) {
              return true;
            }
          }
          return false;
        },
        listener: (context, state) {
          if (state is MySessionDetailError) {
            CommonFlushbar.error(context, state.message);
            return;
          }
          if (state is MySessionDetailLoaded) {
            final bloc = context.read<MySessionDetailBloc>();
            if (state.successMessage != null) {
              CommonFlushbar.success(context, state.successMessage!);
              bloc.add(const ClearDetailFeedback());
            } else if (state.cancelError != null) {
              CommonFlushbar.error(context, state.cancelError!);
              bloc.add(const ClearDetailFeedback());
            }
          }
        },
        builder: (context, state) {
          final isLoading = state.isBusy;

          if (state is MySessionDetailError && !isLoading) {
            return _DetailErrorBody(
              message: state.message,
              onRetry: () => context
                  .read<MySessionDetailBloc>()
                  .add(LoadBookingDetail(bookingId)),
            );
          }

          final booking = state is MySessionDetailLoaded
              ? state.booking
              : BookingDetailModel.placeholder();
          final isCancelling =
              state is MySessionDetailLoaded && state.isCancelling;

          return AutoSkeleton(
            enabled: isLoading,
            child: _DetailBody(
              booking: booking,
              bookingId: bookingId,
              interactionsEnabled: !isLoading,
              isCancelling: isCancelling,
            ),
          );
        },
      ),
    );
  }
}

class _DetailErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetailErrorBody({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final BookingDetailModel booking;
  final String bookingId;
  final bool interactionsEnabled;
  final bool isCancelling;

  const _DetailBody({
    required this.booking,
    required this.bookingId,
    this.interactionsEnabled = true,
    this.isCancelling = false,
  });

  @override
  Widget build(BuildContext context) {
    final status = booking.bookingStatus;
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(booking.bookingDate);
    } catch (_) {}

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: CommonImage(
                        path: 'assets/image/doctorprofile.png',
                        width: 56.w,
                        height: 56.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.healerName,
                            style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            booking.serviceTypeLabel,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    BookingStatusChip(status: status),
                  ],
                ),
                if (interactionsEnabled && booking.isUpcomingConfirmed) ...[
                  SizedBox(height: 14.h),
                  BookingCountdownBanner(
                    target: booking.startDateTime,
                    endTime: booking.endDateTime,
                  ),
                ],
                if (interactionsEnabled && booking.isWaitingForGroupStart) ...[
                  SizedBox(height: 14.h),
                  GroupSessionWaitingCard(booking: booking),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),
          _InfoCard(
            children: [
              _InfoRow(
                label: 'Reference',
                value: booking.bookingReference,
              ),
              _InfoRow(
                label: 'Date',
                value: parsedDate != null
                    ? DateFormat('EEEE, d MMM yyyy').format(parsedDate)
                    : booking.bookingDate,
              ),
              _InfoRow(label: 'Time', value: booking.timeRangeLabel),
              if (booking.consultationLabel.isNotEmpty)
                _InfoRow(
                  label: 'Consultation',
                  value: booking.consultationLabel,
                ),
              _InfoRow(label: 'Session fee', value: '₹${booking.fixedPrice}'),
              _InfoRow(
                label: 'Wallet hold',
                value: '₹${booking.holdAmount}',
              ),
              if (booking.refundLabel.isNotEmpty)
                _InfoRow(label: 'Refund', value: booking.refundLabel),
            ],
          ),
          if (interactionsEnabled) ...[
            SizedBox(height: 24.h),
            if (booking.canJoinSession) ...[
              Text(
                'Join your session',
                style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
              ),
              SizedBox(height: 12.h),
              ...booking.availableJoinActions.map(
                (action) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: SessionJoinOptionTile(
                    action: action,
                    enabled: interactionsEnabled,
                    onTap: () => SessionJoinNavigator.go(
                      context,
                      booking,
                      action,
                    ),
                  ),
                ),
              ),
            ],
            if (status.showReceipt) ...[
              CommonButton(
                text: 'View Receipt',
                onPressed: () => context.push('/receipt'),
                borderRadius: 12.r,
              ),
            ],
            if (status.canCancel) ...[
              if (booking.canJoinSession || status.showReceipt)
                SizedBox(height: 12.h),
              CommonButton(
                text: 'Cancel Booking',
                isLoading: isCancelling,
                isDisabled: isCancelling,
                backgroundColor: Colors.white,
                textColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                borderRadius: 12.r,
                onPressed: () => CancelBookingDialog.show(
                  context: context,
                  onConfirm: (reason) {
                    context.read<MySessionDetailBloc>().add(
                          CancelBooking(
                            bookingId: bookingId,
                            reason: reason,
                          ),
                        );
                  },
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: children),
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
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
