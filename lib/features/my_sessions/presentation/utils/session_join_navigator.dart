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
    final isLive = booking.isLiveBooking;
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
          ),
        );
        break;
    }
  }
}
