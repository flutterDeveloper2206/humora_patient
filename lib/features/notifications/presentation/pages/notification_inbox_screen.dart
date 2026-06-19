import 'package:auto_skeleton/auto_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/utils/common_flushbar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/notification_inbox_models.dart';
import '../bloc/notification_inbox_bloc.dart';
import '../bloc/notification_inbox_event.dart';
import '../bloc/notification_inbox_state.dart';
import '../widgets/notification_list_item.dart';

class NotificationInboxScreen extends StatelessWidget {
  const NotificationInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationInboxBloc()..add(const LoadNotificationInbox()),
      child: const _NotificationInboxView(),
    );
  }
}

class _NotificationInboxView extends StatelessWidget {
  const _NotificationInboxView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Notifications',
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          BlocBuilder<NotificationInboxBloc, NotificationInboxState>(
            builder: (context, state) {
              final canMarkAll = state is NotificationInboxLoaded &&
                  state.unreadCount > 0 &&
                  !state.isRefreshing;
              return TextButton(
                onPressed: canMarkAll
                    ? () => context
                        .read<NotificationInboxBloc>()
                        .add(const MarkAllNotificationsRead())
                    : null,
                child: Text(
                  'Mark all read',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: canMarkAll ? AppColors.primary : AppColors.textHint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationInboxBloc, NotificationInboxState>(
        listenWhen: (prev, curr) {
          if (curr is! NotificationInboxError) return false;
          if (prev is NotificationInboxLoaded && prev.isRefreshing) return false;
          return true;
        },
        listener: (context, state) {
          if (state is NotificationInboxError) {
            CommonFlushbar.error(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is NotificationInboxInitial ||
              state is NotificationInboxLoading ||
              (state is NotificationInboxLoaded && state.isRefreshing);

          final items = state is NotificationInboxLoaded
              ? state.items
              : NotificationInboxItem.placeholderList();

          if (state is NotificationInboxError && !isLoading) {
            return _ErrorBody(
              message: state.message,
              onRetry: () => context
                  .read<NotificationInboxBloc>()
                  .add(const LoadNotificationInbox()),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context
                  .read<NotificationInboxBloc>()
                  .add(const RefreshNotificationInbox());
              await context.read<NotificationInboxBloc>().stream.firstWhere(
                    (s) =>
                        (s is NotificationInboxLoaded && !s.isRefreshing) ||
                        s is NotificationInboxError,
                  );
            },
            child: AutoSkeleton(
              enabled: isLoading,
              child: items.isEmpty && !isLoading
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 120.h),
                        Center(
                          child: Text(
                            'No notifications yet',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return NotificationListItem(
                          item: item,
                          onTap: isLoading
                              ? () {}
                              : () => context
                                  .read<NotificationInboxBloc>()
                                  .add(OpenNotificationItem(item.id)),
                          onDelete: isLoading
                              ? () {}
                              : () => context
                                  .read<NotificationInboxBloc>()
                                  .add(DeleteNotification(item.id)),
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
