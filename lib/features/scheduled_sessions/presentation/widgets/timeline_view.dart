import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/scheduled_sessions_state.dart';
import 'session_card.dart';

class TimelineView extends StatelessWidget {
  final List<ScheduledSession> sessions;
  final ValueChanged<String> onCancelSession;

  const TimelineView({
    super.key,
    required this.sessions,
    required this.onCancelSession,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 48.w,
          top: 0,
          bottom: 0,
          child: Container(width: 1.w, color: const Color(0xFFF1F1F1)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            children: sessions.map((session) {
              final card = SessionCard(
                session: session,
                onCancel: () => onCancelSession(session.id),
                onTap: () => context.push('/my-session/${session.id}'),
              );

              return Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          transform: GradientRotation(7.2),
                          colors: [
                            Color(0xFF1F1F1F),
                            Color(0xFF333333),
                            Color(0xFF525252),
                            Color(0xFF333333),
                            Color(0xFF1F1F1F),
                          ],
                          stops: [0.0, 0.40, 0.55, 0.75, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(9.r),
                        border: Border.all(color: const Color(0xFFF0F0F0)),
                      ),
                      child: Center(
                        child: Text(
                          session.time,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 11.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: session.canCancel
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
                                  child: CommonImage(
                                    path: 'assets/image/gravity-ui_trash-bin.png',
                                    height: 22.w,
                                    width: 22.w,
                                  ),
                                ),
                              ),
                              child: card,
                            )
                          : card,
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
