import '../../data/models/agora_token_models.dart';

abstract class AgoraRepository {
  Future<AgoraTokenResponse> fetchToken(
    String bookingId, {
    bool isLive = false,
    String? liveMode,
  });

  Future<void> notifyJoined({
    required String bookingId,
    required String agoraUid,
  });

  Future<void> notifyLeft({
    required String bookingId,
    String reason = 'Normal',
  });

  Future<void> reconnect({
    required String bookingId,
    required String agoraUid,
  });
}
