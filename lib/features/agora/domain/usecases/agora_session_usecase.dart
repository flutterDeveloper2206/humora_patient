import '../../data/repositories/agora_repository_impl.dart';
import '../repositories/agora_repository.dart';

class AgoraSessionUseCase {
  final AgoraRepository _repository;

  AgoraSessionUseCase({AgoraRepository? repository})
      : _repository = repository ?? AgoraRepositoryImpl();

  Future<void> notifyJoined({
    required String bookingId,
    required String agoraUid,
  }) =>
      _repository.notifyJoined(bookingId: bookingId, agoraUid: agoraUid);

  Future<void> notifyLeft({
    required String bookingId,
    String reason = 'Normal',
  }) =>
      _repository.notifyLeft(bookingId: bookingId, reason: reason);

  Future<void> reconnect({
    required String bookingId,
    required String agoraUid,
  }) =>
      _repository.reconnect(bookingId: bookingId, agoraUid: agoraUid);
}
