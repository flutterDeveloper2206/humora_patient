import 'package:equatable/equatable.dart';

import '../../../healers/data/models/healer_api_models.dart';

class LiveConsultationArgs extends Equatable {
  final String healerId;
  final String healerName;
  final String healerImage;
  final int consultationType;
  final List<LiveCounsellingItem> liveCounselling;
  final bool isHealerOnline;

  const LiveConsultationArgs({
    required this.healerId,
    required this.healerName,
    required this.healerImage,
    required this.consultationType,
    required this.liveCounselling,
    this.isHealerOnline = false,
  });

  LiveConsultationArgs copyWith({
    String? healerId,
    String? healerName,
    String? healerImage,
    int? consultationType,
    List<LiveCounsellingItem>? liveCounselling,
    bool? isHealerOnline,
  }) {
    return LiveConsultationArgs(
      healerId: healerId ?? this.healerId,
      healerName: healerName ?? this.healerName,
      healerImage: healerImage ?? this.healerImage,
      consultationType: consultationType ?? this.consultationType,
      liveCounselling: liveCounselling ?? this.liveCounselling,
      isHealerOnline: isHealerOnline ?? this.isHealerOnline,
    );
  }

  @override
  List<Object?> get props => [
        healerId,
        healerName,
        healerImage,
        consultationType,
        liveCounselling,
        isHealerOnline,
      ];
}
