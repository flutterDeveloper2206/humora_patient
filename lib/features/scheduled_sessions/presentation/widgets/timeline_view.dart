import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:humora_patient/common/widgets/common_image.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../bloc/scheduled_sessions_state.dart';
import 'session_card.dart';

class TimelineView extends StatelessWidget {
  final List<ScheduledSession> sessions;
  final Function(String) onCancelSession;

  const TimelineView({
    super.key,
    required this.sessions,
    required this.onCancelSession,
  });

  @override
  Widget build(BuildContext context) {
    // Range of times as per design
    final times = ['7 AM', '8 AM', '9 AM', '10 AM', '11 AM', '12 AM'];

    return Stack(
      children: [
        // The vertical timeline line
        Positioned(
          left: 48.w,
          top: 0,
          bottom: 0,
          child: Container(width: 1.w, color: const Color(0xFFF1F1F1)),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            children: times.map((time) {
              final session = sessions.firstWhere(
                (s) => s.time == time,
                orElse: () => const ScheduledSession(
                  id: '',
                  healerName: '',
                  healerImage: '',
                  category: '',
                  rating: 0,
                  sessionType: '',
                  time: '',
                ),
              );

              return Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Chip
                    Container(
                      width: 58.w,
                      height: 28.h,

                      decoration: BoxDecoration(
                        gradient:  !(time == '8 AM' || time == '10 AM' || time == '11 AM')
                            ? const LinearGradient(
                          transform: GradientRotation(7.2),
                          colors: [
                            Color(0xFF1F1F1F), // Base Dark
                            Color(0xFF333333), // Base Dark
                            Color(0xFF525252), // Central Shine
                            Color(0xFF333333), // Base Dark
                            Color(0xFF1F1F1F), // Base Dark
                          ],
                          stops: [0.0, 0.40, 0.55, 0.75, 1.0],
                        )
                            : null,
                        color:
                            time == '8 AM' || time == '10 AM' || time == '11 AM'
                            ? const Color(
                                0xFFE5E7EB,
                              ) // Light gray for empty or past
                            : const Color(
                                0xFF1E1E1E,
                              ), // Dark for active sessions
                        borderRadius: BorderRadius.circular(9.r),
                        border: Border.all(color: const Color(0xFFF0F0F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xfFFB5B5B26).withOpacity(0.15),
                            blurRadius: 1.5,
                            spreadRadius: 0,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          time,
                          style: AppTextStyles.bodySmall.copyWith(
                            color:
                                time == '8 AM' ||
                                    time == '10 AM' ||
                                    time == '11 AM'
                                ? const Color(0xFF6B7280)
                                : Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),

                    // Session Card or Spacer
                    Expanded(
                      child: session.id.isNotEmpty
                          ? Dismissible(
                              key: Key(session.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) => onCancelSession(session.id),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 20.w),
                                child: Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF52D56),
                                    shape: BoxShape.circle,
                                  ),
                                  child: CommonImage(path: 'assets/image/gravity-ui_trash-bin.png',height: 22.w,width: 22.w,),
                                ),
                              ),
                              child: SessionCard(
                                session: session,
                                onCancel: () => onCancelSession(session.id),
                              ),
                            )
                          : SizedBox(height: 100.h), // Spacer for empty slots
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
