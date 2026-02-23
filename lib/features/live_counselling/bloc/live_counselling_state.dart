import 'package:equatable/equatable.dart';

enum LiveCounsellingStatus { initial, loading, success, error }

class LiveCounsellingState extends Equatable {
  final double minPrice;
  final double maxPrice;
  final double chatPrice;
  final double audioPrice;
  final double videoPrice;
  final bool isFreeCallEnabled;
  final LiveCounsellingStatus status;
  final String? errorMessage;

  const LiveCounsellingState({
    this.minPrice = 50,
    this.maxPrice = 120,
    this.chatPrice = 5.0,
    this.audioPrice = 8.0,
    this.videoPrice = 8.0,
    this.isFreeCallEnabled = true,
    this.status = LiveCounsellingStatus.initial,
    this.errorMessage,
  });

  LiveCounsellingState copyWith({
    double? minPrice,
    double? maxPrice,
    double? chatPrice,
    double? audioPrice,
    double? videoPrice,
    bool? isFreeCallEnabled,
    LiveCounsellingStatus? status,
    String? errorMessage,
  }) {
    return LiveCounsellingState(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      chatPrice: chatPrice ?? this.chatPrice,
      audioPrice: audioPrice ?? this.audioPrice,
      videoPrice: videoPrice ?? this.videoPrice,
      isFreeCallEnabled: isFreeCallEnabled ?? this.isFreeCallEnabled,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    minPrice,
    maxPrice,
    chatPrice,
    audioPrice,
    videoPrice,
    isFreeCallEnabled,
    status,
    errorMessage,
  ];
}
