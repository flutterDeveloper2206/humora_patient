import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../agora/presentation/models/call_route_args.dart';
import '../../../chat/presentation/models/chat_session_args.dart';
import '../../data/datasource/live_hub_service.dart';
import '../../data/models/live_models.dart';
import '../models/live_consultation_args.dart';

/// When hub/REST omit consultationType it defaults to 0 — keep the type the patient requested.
int resolveLiveConsultationType({
  required int requestedType,
  required int payloadType,
}) {
  if (payloadType == 1 || payloadType == 2) return payloadType;
  if (requestedType == 1 || requestedType == 2) return requestedType;
  return payloadType;
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

/// After healer accepts: join live hub and open chat / voice / video UI.
Future<void> navigateAfterLiveRequestAccepted({
  required BuildContext context,
  required LiveConsultationArgs args,
  required RequestAcceptedPayload payload,
}) async {
  final consultationType = resolveLiveConsultationType(
    requestedType: args.consultationType,
    payloadType: payload.consultationType,
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
