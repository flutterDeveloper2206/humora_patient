import 'package:equatable/equatable.dart';

import '../../data/models/live_models.dart';

abstract class LiveRequestState extends Equatable {
  const LiveRequestState();

  @override
  List<Object?> get props => [];
}

class LiveRequestInitial extends LiveRequestState {}

class LiveRequestLoading extends LiveRequestState {}

class LiveRequestWaiting extends LiveRequestState {
  final String requestId;
  final DateTime? expiresAt;
  final bool hubConnected;

  const LiveRequestWaiting({
    required this.requestId,
    this.expiresAt,
    this.hubConnected = false,
  });

  @override
  List<Object?> get props => [requestId, expiresAt, hubConnected];
}

class LiveRequestQueued extends LiveRequestState {
  final String waitlistId;
  final String healerId;
  final int consultationType;
  final int position;
  final int? estimatedWaitMinutes;
  final DateTime? joinedAt;

  const LiveRequestQueued({
    required this.waitlistId,
    required this.healerId,
    required this.consultationType,
    required this.position,
    this.estimatedWaitMinutes,
    this.joinedAt,
  });

  LiveRequestQueued copyWith({
    String? waitlistId,
    String? healerId,
    int? consultationType,
    int? position,
    int? estimatedWaitMinutes,
    DateTime? joinedAt,
  }) {
    return LiveRequestQueued(
      waitlistId: waitlistId ?? this.waitlistId,
      healerId: healerId ?? this.healerId,
      consultationType: consultationType ?? this.consultationType,
      position: position ?? this.position,
      estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  List<Object?> get props =>
      [waitlistId, healerId, position, estimatedWaitMinutes, joinedAt];
}

class LiveRequestAccepted extends LiveRequestState {
  final RequestAcceptedPayload payload;

  const LiveRequestAccepted(this.payload);

  @override
  List<Object?> get props => [payload];
}

class LiveRequestRejected extends LiveRequestState {
  final String message;

  const LiveRequestRejected([this.message = 'The healer declined your request.']);

  @override
  List<Object?> get props => [message];
}

class LiveRequestExpired extends LiveRequestState {}

class LiveRequestWalletError extends LiveRequestState {
  final LiveInsufficientWalletResponse walletError;

  const LiveRequestWalletError(this.walletError);

  @override
  List<Object?> get props => [walletError];
}

class LiveRequestError extends LiveRequestState {
  final String message;

  const LiveRequestError(this.message);

  @override
  List<Object?> get props => [message];
}
