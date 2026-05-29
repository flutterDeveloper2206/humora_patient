import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../common/widgets/common_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/sessions_bloc.dart';
import '../widgets/day_chip.dart';
import '../widgets/session_timeline_item.dart';
import '../widgets/time_input_chip.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SessionsBloc(),
      child: const SessionsView(),
    );
  }
}

class SessionsView extends StatelessWidget {
  const SessionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(context),
      body: BlocListener<SessionsBloc, SessionsState>(
        listener: (context, state) {
          if (state.status == SessionsStatus.success) {
            context.push(
              '/success',
              extra: {
                'icon': 'assets/images/right.png',
                'imagePath': 'assets/images/complete.png',
                'title': "Thank you!",
                'subtitle':
                    "General session times are now available\nfor any patient.",
                'buttonText': "Got it!",
                'onButtonPressed': (){},
              },
            );
          }
        },
        child: BlocBuilder<SessionsBloc, SessionsState>(
          builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      _buildTopToggles(context, state),
                      // SizedBox(height: 24.h),
                      // _buildAvailabilitySection(context, state),
                      SizedBox(height: 16.h),
                      _buildTimeline(context, state),
                                   SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              _buildBottomButton(context, state),
            ],
          );
        },
      ),
    ));
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
          size: 25.sp,
        ),
      ),
      title: Text("Sessions", style: AppTextStyles.titleMedium),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(0.5.h),
        child: Container(color: AppColors.divider, height: 0.5.h),
      ),
    );
  }

  Widget _buildTopToggles(BuildContext context, SessionsState state) {
    return Row(
      children: [
        Expanded(
          child: _buildToggleItem(
            label: "All Days",
            value: state.isAllDaysEnabled,
            onChanged: (val) =>
                context.read<SessionsBloc>().add(ToggleAllDays(val)),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildToggleItem(
            label: "Week Days",
            value: state.isWeekDaysEnabled,
            onChanged: (val) =>
                context.read<SessionsBloc>().add(ToggleWeekDays(val)),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleItem({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.w, horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38.w,
              height: 22.h,
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11.r),
                color: value ? AppColors.black : const Color(0xFFE5E5E5),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 18.h,
                  height: 18.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  List<Widget> _buildCalendarDays(BuildContext context, SessionsState state) {
    // Generate 7 days starting from baseCalendarDate
    final base = state.baseCalendarDate ?? DateTime.now();
    final baseDate = DateTime(base.year, base.month, base.day);
    return List.generate(7, (index) {
      final date = baseDate.add(Duration(days: index));
      final isSelected =
          date.day == state.selectedDate.day &&
          date.month == state.selectedDate.month &&
          date.year == state.selectedDate.year;
      return DayChip(
        dayName: DateFormat('E').format(date),
        dayNumber: DateFormat('d').format(date),
        isSelected: isSelected,
        onTap: () => context.read<SessionsBloc>().add(SelectDate(date)),
      );
    });
  }

  List<Widget> _buildWeekDays(BuildContext context, SessionsState state) {
    final days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return days.map((day) {
      final isSelected = day == state.selectedWeekDay;
      return DayChip(
        dayName: day,
        dayNumber: "-", // Or hide number for week days
        isSelected: isSelected,
        onTap: () => context.read<SessionsBloc>().add(SelectWeekDay(day)),
      );
    }).toList();
  }

  Widget _buildTimeline(BuildContext context, SessionsState state) {
    final slots = state.currentSlots;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal:  14.w,vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Availability",
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (state.isAllDaysEnabled)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              context.read<SessionsBloc>().add(const ShiftWeek(-1)),
                          child: Icon(
                            Icons.chevron_left,
                            color: AppColors.textSecondary,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () async {
                            final initialDate =
                                state.baseCalendarDate ?? DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365 * 2),
                              ),
                            );
                            if (picked != null) {
                              context.read<SessionsBloc>().add(
                                SetBaseCalendarDate(picked),
                              );
                            }
                          },
                          child: Text(
                            DateFormat(
                              'MMMM yyyy',
                            ).format(state.baseCalendarDate ?? DateTime.now()),
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () =>
                              context.read<SessionsBloc>().add(const ShiftWeek(1)),
                          child: Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                            size: 20.sp,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: state.isAllDaysEnabled
                      ? _buildCalendarDays(context, state)
                      : _buildWeekDays(context, state),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          SessionTimelineItem(
            isFirst: true,
            title: "Live Counselling",
            slots: slots['Live Counselling'] ?? [],
            onAdd: () => context.read<SessionsBloc>().add(
              const AddTimeSlot('Live Counselling'),
            ),
            onRemove: (index) => context.read<SessionsBloc>().add(
              RemoveTimeSlot('Live Counselling', index),
            ),
          ),
          SessionTimelineItem(
            title: "Personal Healing",
            slots: slots['Personal Healing'] ?? [],
            onAdd: () => context.read<SessionsBloc>().add(
              const AddTimeSlot('Personal Healing'),
            ),
            onRemove: (index) => context.read<SessionsBloc>().add(
              RemoveTimeSlot('Personal Healing', index),
            ),
          ),
          SessionTimelineItem(
            isLast: true,
            title: "Group Healing",
            slots: slots['Group Healing'] ?? [],
            onAdd: () => context.read<SessionsBloc>().add(
              const AddTimeSlot('Group Healing'),
            ),
            onRemove: (index) => context.read<SessionsBloc>().add(
              RemoveTimeSlot('Group Healing', index),
            ),
          ),
          SizedBox(height: 16.h),
          Divider(color: AppColors.divider,),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: TimeInputChip(
                  label: "Start Time",
                  time: state.startTime,
                  onTap: () => _selectTime(context, true),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  "—",
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.5),
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              Expanded(
                child: TimeInputChip(
                  label: "End Time",
                  time: state.endTime,
                  onTap: () => _selectTime(context, false),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () {
                  // This confirms the current time selection for the "active" session
                  // Usually we'd use these values when hitting + above
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Time preference updated. Tap + on a session to add.",
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.check, color: AppColors.white, size: 20.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedTime =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      if (isStart) {
        context.read<SessionsBloc>().add(UpdateTempStartTime(formattedTime));
      } else {
        context.read<SessionsBloc>().add(UpdateTempEndTime(formattedTime));
      }
    }
  }

  Widget _buildBottomButton(BuildContext context, SessionsState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      child: CommonButton(
        text: "Confirm",
        isLoading: state.status == SessionsStatus.loading,
        onPressed: () {
          context.read<SessionsBloc>().add(const SubmitSessions());
        },
        borderRadius: 12.r,
      ),
    );
  }
}
