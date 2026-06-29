import 'dart:developer' as developer;

import 'package:go_router/go_router.dart';

import '../../features/live_consultation/presentation/models/live_consultation_args.dart';
import '../../features/live_consultation/presentation/utils/live_request_routing.dart';
import '../../routes/app_router.dart';
import '../incoming_call/models/call_push_type.dart';
import '../incoming_call/incoming_call_controller.dart';
import '../incoming_call/models/incoming_call_payload.dart';
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
    final eventType = payload.eventType;

    if (eventType == CallPushType.callMissed &&
        payload.screen == NotificationScreen.notifications) {
      context.push('/notifications');
      return;
    }

    if (payload.screen == NotificationScreen.incomingCall ||
        eventType == CallPushType.incomingCall) {
      final ring = IncomingCallPayload.tryFromNotificationData(payload.data);
      if (ring != null) {
        IncomingCallController.instance.showRing(ring);
        return;
      }
    }

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
        navigateToLiveConsultation(
          context: context,
          args: LiveConsultationArgs(
            healerId: payload.data['healerId']?.toString() ?? '',
            healerName: payload.data['healerName']?.toString() ?? '',
            healerImage: payload.data['healerImage']?.toString() ?? '',
            consultationType:
                int.tryParse(payload.data['consultationType']?.toString() ?? '') ??
                0,
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
