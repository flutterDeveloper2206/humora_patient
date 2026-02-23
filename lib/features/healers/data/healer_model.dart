import 'package:equatable/equatable.dart';

class HealerModel extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String specialization;
  final int experienceYears;
  final double rating;
  final int reviewsCount;
  final bool isAvailableNow;
  final int feesPerMin;
  final List<HealerAvailability> availability;

  const HealerModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.specialization,
    required this.experienceYears,
    required this.rating,
    required this.reviewsCount,
    required this.isAvailableNow,
    required this.feesPerMin,
    required this.availability,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    imageUrl,
    specialization,
    experienceYears,
    rating,
    reviewsCount,
    isAvailableNow,
    feesPerMin,
    availability,
  ];
}

class HealerAvailability extends Equatable {
  final String date;
  final bool isAvailable;

  const HealerAvailability({required this.date, required this.isAvailable});

  @override
  List<Object?> get props => [date, isAvailable];
}
