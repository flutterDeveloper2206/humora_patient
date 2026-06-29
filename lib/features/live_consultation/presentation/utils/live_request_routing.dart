import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../agora/presentation/models/call_route_args.dart';
import '../../../chat/presentation/models/chat_session_args.dart';
import '../../data/datasource/live_hub_service.dart';
import '../../data/models/live_models.dart';
import '../models/live_consultation_args.dart';
import 'live_waitlist_cache.dart';

/// Patient-selected modality (0 chat, 1 audio, 2 video) wins over hub/REST payload
/// when the server omits or returns a generic type.
int resolveLiveConsultationType({
  required int requestedType,
  required int payloadType,
}) {
  if (requestedType >= 0 && requestedType <= 2) return requestedType;
  if (payloadType >= 0 && payloadType <= 2) return payloadType;
  return 0;
}

CallMode callModeForConsultationType(int consultationType) =>
    switch (consultationType) {
      1 => CallMode.audio,
      2 => CallMode.video,
      _ => CallMode.audio,
    };

RequestAcceptedPayload enrichAcceptedPayload({
  required RequestAcceptedPayload payload,
  required int requestedType,
}) {
  final type = resolveLiveConsultationType(
    requestedType: requestedType,
    payloadType: payload.consultationType,
  );
  if (type == payload.consultationType) return payload;
  return RequestAcceptedPayload(
    bookingId: payload.bookingId,
    bookingReference: payload.bookingReference,
    startedAt: payload.startedAt,
    pricePerMinute: payload.pricePerMinute,
    freeMinutes: payload.freeMinutes,
    consultationType: type,
    agoraToken: payload.agoraToken,
    agoraChannelName: payload.agoraChannelName,
    agoraUid: payload.agoraUid,
  );
}

/// Start live consultation — opens chat / voice / video directly (no waiting screen).
Future<void> navigateToLiveConsultation({
  required BuildContext context,
  required LiveConsultationArgs args,
  bool replaceCurrent = false,
}) async {
  LiveWaitlistCache.instance.remember(args);

  void go(String location, {Object? extra}) {
    if (replaceCurrent) {
      context.pushReplacement(location, extra: extra);
    } else {
      context.push(location, extra: extra);
    }
  }

  switch (args.consultationType.clamp(0, 2)) {
    case 0:
      go(
        '/chat/pending',
        extra: ChatSessionArgs(
          healerName: args.healerName,
          otherUserProfile: args.healerImage,
          isLiveSession: true,
          pendingLiveRequest: PendingLiveChatRequest(
            healerId: args.healerId,
            healerImage: args.healerImage,
            isHealerOnline: args.isHealerOnline,
          ),
        ),
      );
      break;
    case 1:
      go(
        '/voice-call',
        extra: CallRouteArgs(
          bookingId: '',
          healerName: args.healerName,
          healerImageUrl: args.healerImage,
          mode: CallMode.audio,
          isLive: true,
          pendingConsultation: args,
        ),
      );
      break;
    case 2:
      go(
        '/video-call',
        extra: CallRouteArgs(
          bookingId: '',
          healerName: args.healerName,
          healerImageUrl: args.healerImage,
          mode: CallMode.video,
          isLive: true,
          pendingConsultation: args,
        ),
      );
      break;
  }
}

Future<void> navigateAfterLiveRequestAccepted({
  required BuildContext context,
  required LiveConsultationArgs args,
  required RequestAcceptedPayload payload,
  List<String> initialDraftMessages = const [],
}) async {
  // Args carry the modality the patient tapped on the healer card / waitlist.
  final consultationType = args.consultationType.clamp(0, 2);
  LiveWaitlistCache.instance.rememberBookingType(
    payload.bookingId,
    consultationType,
  );

  try {
    await LiveHubService.instance.joinSession(payload.bookingId);
  } catch (_) {}

  if (!context.mounted) return;

  switch (consultationType) {
    case 0:
      context.pushReplacement(
        '/chat/${payload.bookingId}',
        extra: ChatSessionArgs(
          bookingId: payload.bookingId,
          isLiveSession: true,
          healerName: args.healerName,
          otherUserProfile: args.healerImage,
          initialDraftMessages: initialDraftMessages,
        ),
      );
      break;
    case 1:
      context.pushReplacement(
        '/voice-call',
        extra: CallRouteArgs(
          bookingId: payload.bookingId,
          healerName: args.healerName,
          healerImageUrl: args.healerImage,
          isLive: true,
          mode: CallMode.audio,
        ),
      );
      break;
    case 2:
      context.pushReplacement(
        '/video-call',
        extra: CallRouteArgs(
          bookingId: payload.bookingId,
          healerName: args.healerName,
          healerImageUrl: args.healerImage,
          isLive: true,
          mode: CallMode.video,
        ),
      );
      break;
  }
}
