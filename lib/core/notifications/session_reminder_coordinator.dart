import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'notification_payload.dart';
import 'notification_router.dart';
import 'session_hub_service.dart';

/// Shows in-app banner when [SessionReminder] arrives on `/hubs/session`.
class SessionReminderCoordinator extends StatefulWidget {
  final Widget child;

  const SessionReminderCoordinator({super.key, required this.child});

  @override
  State<SessionReminderCoordinator> createState() =>
      _SessionReminderCoordinatorState();
}

class _SessionReminderCoordinatorState extends State<SessionReminderCoordinator> {
  StreamSubscription<SessionReminderPayload>? _subscription;
  SessionReminderPayload? _activeReminder;

  @override
  void initState() {
    super.initState();
    _subscription = SessionHubService.instance.sessionReminder.listen((payload) {
      if (!mounted) return;
      setState(() => _activeReminder = payload);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _dismiss() {
    setState(() => _activeReminder = null);
  }

  Future<void> _openReminder(SessionReminderPayload payload) async {
    _dismiss();
    await NotificationRouter.open(
      NotificationPayload.fromSessionReminder(
        screen: payload.screen,
        bookingId: payload.bookingId,
        message: payload.message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminder = _activeReminder;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        widget.child,
        if (reminder != null)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8.h,
            left: 16.w,
            right: 16.w,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(16.r),
              color: AppColors.white,
              child: InkWell(
                onTap: () => _openReminder(reminder),
                borderRadius: BorderRadius.circular(16.r),
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLite,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.event_available_rounded,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Session Reminder',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              reminder.message,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _dismiss,
                        icon: Icon(Icons.close, size: 18.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
