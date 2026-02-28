import 'package:equatable/equatable.dart';

class HealerEducation extends Equatable {
  final String title;
  final String imagePath;

  const HealerEducation({required this.title, required this.imagePath});

  @override
  List<Object?> get props => [title, imagePath];
}

class HealingService extends Equatable {
  final String type;
  final int callPrice;
  final int videoPrice;
  final int chatPrice;

  const HealingService({
    required this.type,
    required this.callPrice,
    required this.videoPrice,
    required this.chatPrice,
  });

  @override
  List<Object?> get props => [type, callPrice, videoPrice, chatPrice];
}

class HealerServices extends Equatable {
  final HealingService oneToOne;
  final HealingService group;

  const HealerServices({required this.oneToOne, required this.group});

  @override
  List<Object?> get props => [oneToOne, group];
}

class HealerReview extends Equatable {
  final String id;
  final String userName;
  final String userImageUrl;
  final String comment;
  final double rating;
  final String date;

  const HealerReview({
    required this.id,
    required this.userName,
    required this.userImageUrl,
    required this.comment,
    required this.rating,
    required this.date,
  });

  @override
  List<Object?> get props => [
    id,
    userName,
    userImageUrl,
    comment,
    rating,
    date,
  ];
}

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

  final String about;
  final HealerServices? services;

  final String description;
  final List<HealerEducation> education;
  final List<String> experienceDetails;
  final List<HealerReview> reviews;

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
    this.about = '',
    this.services,
    this.description = '',
    this.education = const [],
    this.experienceDetails = const [],
    this.reviews = const [],
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
    about,
    services,
    description,
    education,
    experienceDetails,
    reviews,
  ];
}

class HealerAvailability extends Equatable {
  final String date;
  final bool isAvailable;
  final String day;
  final List<String> periods;

  const HealerAvailability({required this.date, required this.isAvailable,required this.day, required this.periods});

  @override
  List<Object?> get props => [date, isAvailable];
}
