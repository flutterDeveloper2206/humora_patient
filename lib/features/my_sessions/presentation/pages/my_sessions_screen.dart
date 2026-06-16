import 'package:auto_skeleton/auto_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/utils/common_flushbar.dart';
import '../../../../common/utils/safe_navigation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/my_booking_models.dart';
import '../bloc/my_sessions_bloc.dart';
import '../bloc/my_sessions_event.dart';
import '../bloc/my_sessions_state.dart';
import '../utils/my_sessions_loading.dart';
import '../widgets/my_booking_card.dart';
import '../widgets/my_sessions_empty_state.dart';

class MySessionsScreen extends StatelessWidget {
  const MySessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MySessionsBloc()..add(const LoadMySessions()),
      child: const MySessionsView(embedded: false),
    );
  }
}

class MySessionsView extends StatelessWidget {
  final bool embedded;

  const MySessionsView({super.key, this.embedded = true});

  double get _bottomPadding => embedded ? 120 : 32;

  @override
  Widget build(BuildContext context) {
    final content = BlocConsumer<MySessionsBloc, MySessionsState>(
      listenWhen: (prev, curr) {
        if (curr is! MySessionsError) return false;
        if (prev is MySessionsLoaded && prev.isRefreshing) return false;
        return true;
      },
      listener: (context, state) {
        if (state is MySessionsError) {
          CommonFlushbar.error(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state.isBusy;

        if (state is MySessionsError && !isLoading) {
          return _SessionsErrorBody(
            message: state.message,
            bottomPadding: _bottomPadding,
            onRetry: () =>
                context.read<MySessionsBloc>().add(const LoadMySessions()),
          );
        }

        final groups = state is MySessionsLoaded
            ? state.groups
            : MyBookingsGrouper.placeholderGroups();

        final showEmpty = state is MySessionsLoaded &&
            state.isEmpty &&
            !isLoading;

        return AutoSkeleton(
          enabled: isLoading,
          child: showEmpty
              ? const MySessionsEmptyState()
              : _SessionsListContent(
                  groups: groups,
                  bottomPadding: _bottomPadding,
                  interactionsEnabled: !isLoading,
                ),
        );
      },
    );

    if (!embedded) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context, showBack: true),
        body: content,
      );
    }

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAppBar(context, showBack: false),
          Expanded(child: content),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, {required bool showBack}) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: showBack,
      leading: showBack
          ? IconButton(
              icon: Icon(Icons.chevron_left, color: AppColors.textPrimary, size: 28.sp),
              onPressed: () => safePop(context),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Sessions',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
          BlocBuilder<MySessionsBloc, MySessionsState>(
            builder: (context, state) {
              final subtitle = state.isBusy
                  ? 'Loading sessions...'
                  : 'Upcoming & past bookings';
              return Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11.sp,
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        BlocBuilder<MySessionsBloc, MySessionsState>(
          builder: (context, state) {
            return IconButton(
              onPressed: state.isBusy
                  ? null
                  : () => context
                      .read<MySessionsBloc>()
                      .add(const RefreshMySessions()),
              icon: Icon(
                Icons.refresh_rounded,
                size: 22.sp,
                color: state.isBusy
                    ? AppColors.textHint
                    : AppColors.textPrimary,
              ),
            );
          },
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}

class _SessionsListContent extends StatelessWidget {
  final List<BookingDateGroup> groups;
  final double bottomPadding;
  final bool interactionsEnabled;

  const _SessionsListContent({
    required this.groups,
    required this.bottomPadding,
    this.interactionsEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: interactionsEnabled
          ? () async {
              final bloc = context.read<MySessionsBloc>();
              bloc.add(const RefreshMySessions());
              await bloc.stream.firstWhere(
                (s) =>
                    (s is MySessionsLoaded && !s.isRefreshing) ||
                    s is MySessionsError,
              );
            }
          : () async {},
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, bottomPadding.h),
        itemCount: groups.length,
        itemBuilder: (context, groupIndex) {
          final group = groups[groupIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(
                  bottom: 12.h,
                  top: groupIndex > 0 ? 12.h : 0,
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryLite,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.primaryLiteChip.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      group.dateHeader,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              ...group.bookings.map(
                (booking) => MyBookingCard(
                  booking: booking,
                  onTap: interactionsEnabled
                      ? () => context.push('/my-session/${booking.id}')
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SessionsErrorBody extends StatelessWidget {
  final String message;
  final double bottomPadding;
  final VoidCallback onRetry;

  const _SessionsErrorBody({
    required this.message,
    required this.bottomPadding,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, bottomPadding.h),
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
