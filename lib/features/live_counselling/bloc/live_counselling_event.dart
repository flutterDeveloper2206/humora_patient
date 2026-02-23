import 'package:equatable/equatable.dart';

abstract class LiveCounsellingEvent extends Equatable {
  const LiveCounsellingEvent();

  @override
  List<Object?> get props => [];
}

class UpdateMinPrice extends LiveCounsellingEvent {
  final double price;
  const UpdateMinPrice(this.price);
  @override
  List<Object?> get props => [price];
}

class UpdateMaxPrice extends LiveCounsellingEvent {
  final double price;
  const UpdateMaxPrice(this.price);
  @override
  List<Object?> get props => [price];
}

class UpdateChatPrice extends LiveCounsellingEvent {
  final double price;
  const UpdateChatPrice(this.price);
  @override
  List<Object?> get props => [price];
}

class UpdateAudioPrice extends LiveCounsellingEvent {
  final double price;
  const UpdateAudioPrice(this.price);
  @override
  List<Object?> get props => [price];
}

class UpdateVideoPrice extends LiveCounsellingEvent {
  final double price;
  const UpdateVideoPrice(this.price);
  @override
  List<Object?> get props => [price];
}

class ToggleFreeCall extends LiveCounsellingEvent {}

class SubmitLiveCounselling extends LiveCounsellingEvent {}
