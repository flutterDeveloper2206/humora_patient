import 'dart:developer' as developer;

import 'package:go_router/go_router.dart';

import '../../features/live_consultation/presentation/models/live_consultation_args.dart';
import '../../routes/app_router.dart';
import 'notification_payload.dart';
import 'notification_screen.dart';

class NotificationRouter {
  NotificationRouter._();

  static Future<void> open(NotificationPayload payload) async {
    final context = AppRouter.rootNavigatorKey.currentContext;
    if (context == null) {
      developer.log(
        'NotificationRouter → no navigator context',
        name: 'NotificationRouter',
      );
      return;
    }

    final bookingId = payload.bookingId;

    switch (payload.screen) {
      case NotificationScreen.bookingDetail:
      case NotificationScreen.sessionActive:
        if (bookingId != null) {
          context.push('/my-session/$bookingId');
          return;
        }
        context.push('/my-sessions');
        return;
      case NotificationScreen.liveJoin:
        if (bookingId != null) {
          context.push('/my-session/$bookingId');
          return;
        }
        context.push('/home');
        return;
      case NotificationScreen.liveSession:
        context.push(
          '/live-request-waiting',
          extra: LiveConsultationArgs(
            healerId: payload.data['healerId']?.toString() ?? '',
            healerName: payload.data['healerName']?.toString() ?? '',
            healerImage: payload.data['healerImage']?.toString() ?? '',
            consultationType: 0,
            liveCounselling: const [],
          ),
        );
        return;
      case NotificationScreen.walletEarnings:
        context.push('/wallet');
        return;
      case NotificationScreen.home:
      case NotificationScreen.dashboard:
      case NotificationScreen.healerOnboarding:
      default:
        context.push('/home');
        return;
    }
  }
}
