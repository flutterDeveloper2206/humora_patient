import 'package:equatable/equatable.dart';

import '../../../healers/data/models/healer_api_models.dart';

class LiveConsultationArgs extends Equatable {
  final String healerId;
  final String healerName;
  final String healerImage;
  final int consultationType;
  final List<LiveCounsellingItem> liveCounselling;

  const LiveConsultationArgs({
    required this.healerId,
    required this.healerName,
    required this.healerImage,
    required this.consultationType,
    required this.liveCounselling,
  });

  LiveConsultationArgs copyWith({
    String? healerId,
    String? healerName,
    String? healerImage,
    int? consultationType,
    List<LiveCounsellingItem>? liveCounselling,
  }) {
    return LiveConsultationArgs(
      healerId: healerId ?? this.healerId,
      healerName: healerName ?? this.healerName,
      healerImage: healerImage ?? this.healerImage,
      consultationType: consultationType ?? this.consultationType,
      liveCounselling: liveCounselling ?? this.liveCounselling,
    );
  }

  @override
  List<Object?> get props => [
        healerId,
        healerName,
        healerImage,
        consultationType,
        liveCounselling,
      ];
}
