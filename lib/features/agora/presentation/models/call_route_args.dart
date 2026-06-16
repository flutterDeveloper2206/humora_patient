import 'package:equatable/equatable.dart';

import '../../data/models/agora_token_models.dart';

enum CallMode { audio, video, group }

class CallRouteArgs extends Equatable {
  final String bookingId;
  final String healerName;
  final String? healerImageUrl;
  final CallMode mode;
  final bool isLive;
  /// Agora credentials from RequestAccepted when backend includes them.
  final AgoraTokenResponse? prefetchedToken;

  const CallRouteArgs({
    required this.bookingId,
    required this.healerName,
    this.healerImageUrl,
    required this.mode,
    this.isLive = false,
    this.prefetchedToken,
  });

  @override
  List<Object?> get props => [
        bookingId,
        healerName,
        healerImageUrl,
        mode,
        isLive,
        prefetchedToken,
      ];
}
