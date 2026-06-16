import '../../data/models/agora_token_models.dart';
import '../../data/repositories/agora_repository_impl.dart';
import '../repositories/agora_repository.dart';

class FetchAgoraTokenUseCase {
  final AgoraRepository _repository;

  FetchAgoraTokenUseCase({AgoraRepository? repository})
      : _repository = repository ?? AgoraRepositoryImpl();

  Future<AgoraTokenResponse> call(
    String bookingId, {
    bool isLive = false,
    String? liveMode,
  }) =>
      _repository.fetchToken(
        bookingId,
        isLive: isLive,
        liveMode: liveMode,
      );

  /// Live sessions may need a moment after accept before token is ready.
  Future<AgoraTokenResponse> callWithRetry(
    String bookingId, {
    bool isLive = false,
    String? liveMode,
    int attempts = 4,
  }) async {
    Object? lastError;
    for (var attempt = 0; attempt < attempts; attempt++) {
      try {
        final response = await call(
          bookingId,
          isLive: isLive,
          liveMode: liveMode,
        );
        if (response.isValid) return response;
        lastError = Exception(
          'Call credentials were empty. The session may still be starting.',
        );
      } catch (e) {
        lastError = e;
      }
      if (attempt < attempts - 1) {
        await Future<void>.delayed(
          Duration(milliseconds: 900 * (attempt + 1)),
        );
      }
    }
    throw lastError ?? Exception('Unable to obtain call credentials');
  }
}
