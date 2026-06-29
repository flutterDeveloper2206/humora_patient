import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/utils/common_flushbar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/scheduled_sessions_bloc.dart';
import '../bloc/scheduled_sessions_event.dart';
import '../bloc/scheduled_sessions_state.dart';
import '../widgets/date_selector.dart';
import '../widgets/empty_sessions_state.dart';
import '../widgets/timeline_view.dart';

class ScheduledSessionsScreen extends StatelessWidget {
  const ScheduledSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScheduledSessionsBloc()..add(const LoadCalendar()),
      child: const ScheduledSessionsView(),
    );
  }
}

class ScheduledSessionsView extends StatelessWidget {
  const ScheduledSessionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: BlocConsumer<ScheduledSessionsBloc, ScheduledSessionsState>(
        listenWhen: (prev, curr) =>
            curr.errorMessage != null &&
            (prev.errorMessage != curr.errorMessage) &&
            curr.allSessions.isNotEmpty,
        listener: (context, state) {
          if (state.errorMessage != null) {
            CommonFlushbar.error(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              DateSelector(
                selectedDate: state.selectedDate,
                onDateSelected: (date) {
                  context.read<ScheduledSessionsBloc>().add(SelectDate(date));
                },
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ScheduledSessionsState state) {
    if (state.isLoading && state.allSessions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.errorMessage != null && state.allSessions.isEmpty) {
      return _ErrorBody(
        message: state.errorMessage!,
        onRetry: () =>
            context.read<ScheduledSessionsBloc>().add(const LoadCalendar()),
      );
    }

    if (state.sessions.isEmpty) {
      return const EmptySessionsState();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        final bloc = context.read<ScheduledSessionsBloc>();
        bloc.add(const RefreshCalendar());
        await bloc.stream.firstWhere(
          (s) => !s.isBusy || s.errorMessage != null,
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: TimelineView(
          sessions: state.sessions,
          onCancelSession: (id) {
            context.read<ScheduledSessionsBloc>().add(CancelSession(id));
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.chevron_left, color: Colors.black, size: 25.sp),
        onPressed: () => context.pop(),
      ),
      title: Text('Scheduled Sessions', style: AppTextStyles.titleMedium),
      centerTitle: false,
      actions: [
        BlocBuilder<ScheduledSessionsBloc, ScheduledSessionsState>(
          builder: (context, state) {
            return IconButton(
              onPressed: state.isBusy
                  ? null
                  : () => context.read<ScheduledSessionsBloc>().add(
                      const RefreshCalendar(),
                    ),
              icon: Icon(
                Icons.refresh_rounded,
                color: state.isBusy ? AppColors.textHint : Colors.black,
                size: 22.sp,
              ),
            );
          },
        ),
        SizedBox(width: 10.w),
      ],
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
