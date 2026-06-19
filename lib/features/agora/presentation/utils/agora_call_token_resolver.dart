import '../../data/models/agora_token_models.dart';
import '../../domain/usecases/fetch_agora_token_usecase.dart';
import '../models/call_route_args.dart';
import '../utils/agora_rtc_logging.dart';
import 'agora_token_merge.dart';

/// Fetches patient-specific RTC credentials for live / scheduled calls.
class AgoraCallTokenResolver {
  AgoraCallTokenResolver._();

  static String? liveModeFor(CallRouteArgs args) {
    if (!args.isLive) return null;
    return switch (args.mode) {
      CallMode.audio => 'audio',
      CallMode.video => 'video',
      CallMode.group => 'group',
    };
  }

  static Future<AgoraTokenResponse> resolve({
    required CallRouteArgs args,
    FetchAgoraTokenUseCase? fetchToken,
  }) async {
    final prefetched = args.prefetchedToken;
    if (prefetched != null && prefetched.isValid) {
      final merged = mergeAgoraCredentials(
        token: prefetched,
        agoraInfo: args.prefetchedAgoraInfo,
      );
      AgoraRtcLogger.credentialsFromServer(
        source: 'prefetched (route args)',
        bookingId: args.bookingId,
        response: merged,
      );
      return merged;
    }

    final useCase = fetchToken ?? FetchAgoraTokenUseCase();
    final response = await useCase.callWithRetry(
      args.bookingId,
      isLive: args.isLive,
      liveMode: liveModeFor(args),
    );

    final merged = mergeAgoraCredentials(
      token: response,
      agoraInfo: args.prefetchedAgoraInfo,
    );

    AgoraRtcLogger.credentialsFromServer(
      source: args.isLive ? 'POST /agora/token (live)' : 'POST /agora/token',
      bookingId: args.bookingId,
      response: merged,
    );

    if (!merged.isValid) {
      throw Exception(
        'Call credentials from server were incomplete. Please retry.',
      );
    }

    return merged;
  }
}
