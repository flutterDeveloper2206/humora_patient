import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:humora_patient/core/constants/app_colors.dart';
import 'package:humora_patient/features/healers/presentation/widgets/healer_card.dart';
import 'package:humora_patient/common/widgets/common_image.dart';
import 'package:humora_patient/core/constants/app_text_styles.dart';
import 'package:humora_patient/features/healers/data/models/healer_model.dart';
import 'package:humora_patient/features/appointment_reminder/presentation/bloc/appointment_reminder_bloc.dart';
import 'package:humora_patient/features/appointment_reminder/presentation/bloc/appointment_reminder_event.dart';
import 'package:humora_patient/features/appointment_reminder/presentation/bloc/appointment_reminder_state.dart';
import 'package:humora_patient/features/appointment_reminder/data/models/appointment_reminder_model.dart';
import 'package:humora_patient/features/appointment_reminder/presentation/widgets/reminder_action_button.dart';

class AppointmentReminderScreen extends StatelessWidget {
  const AppointmentReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for initial display as per the objective
    final dummyHealer = HealerModel(
      id: '1',
      name: 'Dr. Hannibal Lector',
      imageUrl: 'assets/image/doctorprofile.png',
      specialization: 'Emotional Healing',
      experienceYears: 5,
      rating: 4.5,
      reviewsCount: 999,
      isAvailableNow: true,
      feesPerMin: 50,
      availability: const [],
    );

    final dummyAppointment = AppointmentReminderModel(
      healer: dummyHealer,
      appointmentTime: DateTime(2025, 1, 23, 10, 0),
    );

    return BlocProvider(
      create: (context) =>
          AppointmentReminderBloc()
            ..add(LoadAppointmentReminder(dummyAppointment)),
      child: const AppointmentReminderView(),
    );
  }
}

class AppointmentReminderView extends StatelessWidget {
  const AppointmentReminderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLite,
      body: BlocBuilder<AppointmentReminderBloc, AppointmentReminderState>(
        builder: (context, state) {
          if (state.status == AppointmentReminderStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.appointment == null) {
            return const Center(child: Text('No appointment found'));
          }

          final appointment = state.appointment!;

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Top Illustration
                        SizedBox(
                          width: double.infinity,
                          height: 316.h,
                          child: CommonImage(
                            path: 'assets/image/healingsuccess.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Column(
                            children: [
                              SizedBox(height: 16.h),
                              Text(
                                'Time for your remote appointment, Let’s Connect!',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.h2.copyWith(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'You have an appointment right now.\nLet’s decide what to do.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 16.sp,
                                  color: const Color(0xFF4E4F53),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 32.h),
                              HealerCard(
                                isNext: false,
                                healer: HealerModel(
                                  id: '1',
                                  name: 'Dr. Hannibal Lector',
                                  imageUrl: 'assets/image/111.png',
                                  specialization: 'Emotional Healing',
                                  experienceYears: 5,
                                  rating: 4.5,
                                  reviewsCount: 999,
                                  isAvailableNow: true,
                                  feesPerMin: 30,
                                  availability: const [],
                                ),
                                onTap: () {
                                  context.push('/scheduled-sessions');
                                },
                              ),
                              SizedBox(height: 40.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom Actions
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ReminderActionButton(
                        label: 'Join Call',
                        icon: Icons.call,
                        color: const Color(0xFF00BFA5),
                        onTap: () {
                          // TODO: Implement Join Call logic
                        },
                      ),
                      ReminderActionButton(
                        label: 'Reschedule Call',
                        icon: Icons.calendar_today_outlined,
                        color: const Color(0xFFFFA000),
                        onTap: () {
                          // TODO: Implement Reschedule logic
                        },
                      ),
                      ReminderActionButton(
                        label: 'Decline Call',
                        icon: Icons.phone_disabled_rounded,
                        color: const Color(0xFFF52D56),
                        onTap: () {
                          context.pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
