import 'dart:async';

import '../../data/models/agora_token_models.dart';
import '../../domain/usecases/fetch_agora_token_usecase.dart';
import '../models/call_route_args.dart';
import '../services/agora_rtc_service.dart';
import 'agora_call_token_resolver.dart';
import 'agora_token_merge.dart';

/// Refreshes RTC token ~5 minutes before [AgoraTokenResponse.expiresAt].
class AgoraTokenRefreshScheduler {
  final FetchAgoraTokenUseCase _fetchToken;
  final AgoraRtcService _rtc;
  Timer? _timer;

  AgoraTokenRefreshScheduler({
    FetchAgoraTokenUseCase? fetchToken,
    required AgoraRtcService rtc,
  })  : _fetchToken = fetchToken ?? FetchAgoraTokenUseCase(),
        _rtc = rtc;

  void schedule({
    required CallRouteArgs args,
    required AgoraTokenResponse tokenResponse,
  }) {
    _timer?.cancel();
    final expiresAt = tokenResponse.expiresAt;
    if (expiresAt == null) return;

    final refreshAt = expiresAt.subtract(const Duration(minutes: 5));
    var delay = refreshAt.difference(DateTime.now());
    if (delay.isNegative) {
      delay = Duration.zero;
    }

    _timer = Timer(delay, () => _refresh(args));
  }

  Future<void> _refresh(CallRouteArgs args) async {
    try {
      final fresh = await _fetchToken.call(
        args.bookingId,
        isLive: args.isLive,
        liveMode: AgoraCallTokenResolver.liveModeFor(args),
      );
      final merged = mergeAgoraCredentials(
        token: fresh,
        agoraInfo: args.prefetchedAgoraInfo,
      );
      if (!merged.isValid || merged.token.isEmpty) return;

      await _rtc.renewToken(merged.token);
      schedule(args: args, tokenResponse: merged);
    } catch (_) {
      // Next invalidToken event from SDK will retry join if needed.
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
