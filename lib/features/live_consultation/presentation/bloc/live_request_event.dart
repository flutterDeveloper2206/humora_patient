import 'package:equatable/equatable.dart';

abstract class LiveRequestEvent extends Equatable {
  const LiveRequestEvent();

  @override
  List<Object?> get props => [];
}

class StartRequest extends LiveRequestEvent {
  final String healerId;
  final int consultationType;

  const StartRequest({
    required this.healerId,
    required this.consultationType,
  });

  @override
  List<Object?> get props => [healerId, consultationType];
}

class CancelRequest extends LiveRequestEvent {
  const CancelRequest();
}

class RetryRequest extends LiveRequestEvent {
  const RetryRequest();
}

class PollRequestStatus extends LiveRequestEvent {
  const PollRequestStatus();
}
