import '../../data/models/agora_token_models.dart';
import '../../domain/usecases/fetch_agora_token_usecase.dart';
import '../models/call_route_args.dart';

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
    final useCase = fetchToken ?? FetchAgoraTokenUseCase();
    final response = await useCase.callWithRetry(
      args.bookingId,
      isLive: args.isLive,
      liveMode: liveModeFor(args),
    );

    if (!response.isValid) {
      throw Exception(
        'Call credentials from server were incomplete. Please retry.',
      );
    }

    return response;
  }
}
