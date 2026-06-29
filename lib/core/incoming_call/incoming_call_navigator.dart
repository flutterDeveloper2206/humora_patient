import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/agora/data/models/agora_token_models.dart';
import '../../core/constants/agora_config.dart';
import '../../features/agora/domain/usecases/fetch_agora_token_usecase.dart';
import '../../features/agora/presentation/models/call_route_args.dart';
import '../../features/chat/presentation/models/chat_session_args.dart';
import '../../features/live_consultation/data/datasource/live_api_service.dart';
import '../../features/live_consultation/data/datasource/live_hub_service.dart';
import '../../features/live_consultation/presentation/utils/live_request_routing.dart';
import '../../routes/app_router.dart';
import 'incoming_call_controller.dart';
import 'models/incoming_call_payload.dart';

/// Accept / reject actions and navigation after a call connects.
class IncomingCallNavigator {
  IncomingCallNavigator._();

  static final LiveApiService _liveApi = LiveApiService();
  static final FetchAgoraTokenUseCase _fetchToken = FetchAgoraTokenUseCase();

  static Future<void> accept(IncomingCallPayload payload) async {
    final controller = IncomingCallController.instance;
    if (controller.isProcessing) return;
    controller.setProcessing(true);

    try {
      AgoraTokenResponse? prefetchedToken;
      var consultationType = payload.consultationType;

      if (payload.isLive &&
          payload.requestId != null &&
          payload.requestId!.isNotEmpty) {
        try {
          final accepted =
              await _liveApi.acceptLiveRequest(payload.requestId!);
          consultationType = accepted.consultationType;
          if (accepted.hasAgoraCredentials) {
            prefetchedToken = AgoraTokenResponse(
              appId: AgoraConfig.appId,
              channelName: accepted.agoraChannelName!,
              token: accepted.agoraToken!,
              uid: int.tryParse(accepted.agoraUid ?? '') ?? 0,
              agoraUid: accepted.agoraUid ?? '',
            );
          }
        } catch (e) {
          developer.log(
            'live/accept failed, falling back to agora/token: $e',
            name: 'IncomingCallNavigator',
          );
        }
      }

      try {
        await LiveHubService.instance.joinSession(payload.bookingId);
      } catch (_) {}

      prefetchedToken ??= await _fetchToken(
        payload.bookingId,
        isLive: payload.isLive,
      );

      final context = AppRouter.rootNavigatorKey.currentContext;
      if (context == null || !context.mounted) return;

      controller.dismiss(callId: payload.callId);

      final healerName = payload.callerName;
      final healerImage = payload.callerPhoto;

      switch (consultationType) {
        case 0:
          context.pushReplacement(
            '/chat/${payload.bookingId}',
            extra: ChatSessionArgs(
              bookingId: payload.bookingId,
              isLiveSession: payload.isLive,
              healerName: healerName,
            ),
          );
          break;
        case 1:
          context.pushReplacement(
            '/voice-call',
            extra: CallRouteArgs(
              bookingId: payload.bookingId,
              healerName: healerName,
              healerImageUrl: healerImage,
              isLive: payload.isLive,
              mode: CallMode.audio,
              prefetchedToken: prefetchedToken,
            ),
          );
          break;
        case 2:
          context.pushReplacement(
            '/video-call',
            extra: CallRouteArgs(
              bookingId: payload.bookingId,
              healerName: healerName,
              healerImageUrl: healerImage,
              isLive: payload.isLive,
              mode: CallMode.video,
              prefetchedToken: prefetchedToken,
            ),
          );
          break;
        default:
          context.pushReplacement(
            '/voice-call',
            extra: CallRouteArgs(
              bookingId: payload.bookingId,
              healerName: healerName,
              healerImageUrl: healerImage,
              isLive: payload.isLive,
              mode: callModeForConsultationType(consultationType),
              prefetchedToken: prefetchedToken,
            ),
          );
      }
    } catch (e) {
      developer.log('accept failed: $e', name: 'IncomingCallNavigator');
      final context = AppRouter.rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
            ),
          ),
        );
      }
    } finally {
      IncomingCallController.instance.setProcessing(false);
      IncomingCallController.instance.dismiss(callId: payload.callId);
    }
  }

  static Future<void> reject(IncomingCallPayload payload) async {
    IncomingCallController.instance.dismiss(callId: payload.callId);
    final requestId = payload.requestId;
    if (payload.isLive && requestId != null && requestId.isNotEmpty) {
      try {
        await _liveApi.rejectLiveRequest(requestId);
      } catch (e) {
        developer.log('live/reject failed: $e', name: 'IncomingCallNavigator');
      }
    }
  }

  /// Patient called healer; healer answered (`call_accepted` push).
  static Future<void> joinAcceptedCall({
    required String bookingId,
    String? healerName,
    int consultationType = 1,
    bool isLive = true,
  }) async {
    try {
      await LiveHubService.instance.joinSession(bookingId);
    } catch (_) {}

    final context = AppRouter.rootNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    final name = healerName ?? 'Healer';
    switch (consultationType) {
      case 0:
        context.pushReplacement(
          '/chat/$bookingId',
          extra: ChatSessionArgs(
            bookingId: bookingId,
            isLiveSession: isLive,
            healerName: name,
          ),
        );
        break;
      case 2:
        context.pushReplacement(
          '/video-call',
          extra: CallRouteArgs(
            bookingId: bookingId,
            healerName: name,
            isLive: isLive,
            mode: CallMode.video,
          ),
        );
        break;
      default:
        context.pushReplacement(
          '/voice-call',
          extra: CallRouteArgs(
            bookingId: bookingId,
            healerName: name,
            isLive: isLive,
            mode: CallMode.audio,
          ),
        );
    }
  }
}
