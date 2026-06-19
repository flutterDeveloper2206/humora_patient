import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../agora/presentation/models/call_route_args.dart';
import '../../../chat/presentation/models/chat_session_args.dart';
import '../../data/models/my_booking_models.dart';
import '../../domain/session_join_resolver.dart';

class SessionJoinNavigator {
  SessionJoinNavigator._();

  static void go(
    BuildContext context,
    BookingDetailModel booking,
    SessionJoinAction action,
  ) {
    _navigate(context, booking, action);
  }

  static void goFromList(
    BuildContext context,
    MyBookingModel booking,
    SessionJoinAction action,
  ) {
    _navigate(context, booking.toDetailModel(), action);
  }

  /// Opens detail when consultation type is unknown; otherwise joins directly.
  static void joinOrOpenDetail(BuildContext context, MyBookingModel booking) {
    final actions = booking.availableJoinActions;
    if (actions.isEmpty || booking.consultationType == null) {
      context.push('/my-session/${booking.id}');
      return;
    }
    goFromList(context, booking, actions.first);
  }

  static void _navigate(
    BuildContext context,
    BookingDetailModel booking,
    SessionJoinAction action,
  ) {
    final isLive = booking.isLiveBooking;
    final agoraInfo = booking.agoraInfo;

    switch (action) {
      case SessionJoinAction.chat:
        context.push(
          '/chat/${booking.id}',
          extra: ChatSessionArgs(
            bookingId: booking.id,
            healerName: booking.healerName,
            isLiveSession: isLive,
          ),
        );
        break;
      case SessionJoinAction.voiceCall:
        context.push(
          '/voice-call',
          extra: CallRouteArgs(
            bookingId: booking.id,
            healerName: booking.healerName,
            mode: CallMode.audio,
            isLive: isLive,
            prefetchedAgoraInfo: agoraInfo,
          ),
        );
        break;
      case SessionJoinAction.videoCall:
      case SessionJoinAction.liveSession:
        context.push(
          '/video-call',
          extra: CallRouteArgs(
            bookingId: booking.id,
            healerName: booking.healerName,
            mode: CallMode.video,
            isLive: isLive,
            prefetchedAgoraInfo: agoraInfo,
          ),
        );
        break;
      case SessionJoinAction.groupSession:
        context.push(
          '/group-session',
          extra: CallRouteArgs(
            bookingId: booking.id,
            healerName: booking.healerName,
            mode: CallMode.group,
            prefetchedAgoraInfo: agoraInfo,
          ),
        );
        break;
    }
  }
}
