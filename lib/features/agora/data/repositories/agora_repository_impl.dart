import '../../domain/repositories/agora_repository.dart';
import '../datasource/agora_token_api_service.dart';
import '../models/agora_token_models.dart';

class AgoraRepositoryImpl implements AgoraRepository {
  final AgoraTokenApiService _apiService;

  AgoraRepositoryImpl({AgoraTokenApiService? apiService})
      : _apiService = apiService ?? AgoraTokenApiService();

  @override
  Future<AgoraTokenResponse> fetchToken(
    String bookingId, {
    bool isLive = false,
    String? liveMode,
  }) =>
      _apiService.fetchToken(
        bookingId,
        isLive: isLive,
        liveMode: liveMode,
      );

  @override
  Future<void> notifyJoined({
    required String bookingId,
    required String agoraUid,
  }) =>
      _apiService.notifyJoined(bookingId: bookingId, agoraUid: agoraUid);

  @override
  Future<void> notifyLeft({
    required String bookingId,
    String reason = 'Normal',
  }) =>
      _apiService.notifyLeft(bookingId: bookingId, reason: reason);

  @override
  Future<void> reconnect({
    required String bookingId,
    required String agoraUid,
  }) =>
      _apiService.reconnect(bookingId: bookingId, agoraUid: agoraUid);
}
