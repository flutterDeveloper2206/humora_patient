import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../bloc/scheduled_sessions_bloc.dart';
import '../../bloc/scheduled_sessions_event.dart';
import '../../bloc/scheduled_sessions_state.dart';
import '../widgets/date_selector.dart';
import '../widgets/empty_sessions_state.dart';
import '../widgets/timeline_view.dart';

class ScheduledSessionsScreen extends StatelessWidget {
  const ScheduledSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ScheduledSessionsBloc()..add(LoadSessions(DateTime(2025, 9, 25))),
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
      body: BlocBuilder<ScheduledSessionsBloc, ScheduledSessionsState>(
        builder: (context, state) {
          return Column(
            children: [
              DateSelector(
                selectedDate: state.selectedDate,
                onDateSelected: (date) {
                  context.read<ScheduledSessionsBloc>().add(LoadSessions(date));
                },
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.sessions.isEmpty
                    ? const EmptySessionsState()
                    : SingleChildScrollView(
                        child: TimelineView(
                          sessions: state.sessions,
                          onCancelSession: (id) {
                            context.read<ScheduledSessionsBloc>().add(
                              CancelSession(id),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
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
      title: Text(
        'Scheduled Sessions',
        style: AppTextStyles.titleMedium
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.calendar_today_outlined,
            color: Colors.black,
            size: 22.sp,
          ),
        ),
        SizedBox(width: 10.w),
      ],
    );
  }
}
