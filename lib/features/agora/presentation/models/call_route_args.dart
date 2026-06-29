import 'package:equatable/equatable.dart';

import '../../data/models/agora_info.dart';
import '../../data/models/agora_token_models.dart';
import '../../../live_consultation/presentation/models/live_consultation_args.dart';

enum CallMode { audio, video, group }

class CallRouteArgs extends Equatable {
  final String bookingId;
  final String healerName;
  final String? healerImageUrl;
  final CallMode mode;
  final bool isLive;
  /// Agora credentials from RequestAccepted when backend includes them.
  final AgoraTokenResponse? prefetchedToken;
  /// Channel preview from booking `agoraInfo` (token fetched on join).
  final AgoraInfo? prefetchedAgoraInfo;
  /// Outbound live call before healer accepts — [bookingId] may be empty.
  final LiveConsultationArgs? pendingConsultation;

  const CallRouteArgs({
    required this.bookingId,
    required this.healerName,
    this.healerImageUrl,
    required this.mode,
    this.isLive = false,
    this.prefetchedToken,
    this.prefetchedAgoraInfo,
    this.pendingConsultation,
  });

  bool get isPendingLiveRequest =>
      pendingConsultation != null && bookingId.isEmpty;

  @override
  List<Object?> get props => [
        bookingId,
        healerName,
        healerImageUrl,
        mode,
        isLive,
        prefetchedToken,
        prefetchedAgoraInfo,
        pendingConsultation,
      ];
}
