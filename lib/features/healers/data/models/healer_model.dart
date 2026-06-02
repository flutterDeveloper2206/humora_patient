import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'healer_api_models.dart';

enum ConsultationType {
  chat(0),
  audio(1),
  video(2);

  final int value;
  const ConsultationType(this.value);

  static ConsultationType fromValue(int val) {
    return ConsultationType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => ConsultationType.chat,
    );
  }
}

enum SessionType {
  live(1),
  personal(2),
  group(3);

  final int value;
  const SessionType(this.value);

  static SessionType fromValue(int val) {
    return SessionType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => SessionType.personal,
    );
  }

  String get label => switch (this) {
        SessionType.live => 'Live',
        SessionType.personal => 'Personal',
        SessionType.group => 'Group',
      };
}

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
  final List<SessionSlotItem> rawSlots;
  final List<SessionPricingItem> sessionPricing;
  final List<LiveCounsellingItem> liveCounsellingPricing;

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
    this.rawSlots = const [],
    this.sessionPricing = const [],
    this.liveCounsellingPricing = const [],
  });

  factory HealerModel.fromApi(ApprovedHealerItem item) {
    // Determine minimum price per minute from liveCounselling
    int minPrice = 0;
    if (item.liveCounselling.isNotEmpty) {
      minPrice = item.liveCounselling
          .map((c) => c.pricePerMinute)
          .reduce((a, b) => a < b ? a : b);
    }

    // Map session slots to availability
    // Note: this is a simple mapping. A full implementation would group by date.
    final availability = item.sessionSlots.map((slot) {
      DateTime dt;
      String dayStr = '';
      String dateStr = '';
      try {
        dt = DateTime.parse(slot.date);
        dayStr = DateFormat('E').format(dt);
        dateStr = DateFormat('MMM dd').format(dt);
      } catch (_) {}

      // Convert startTime to a string period based on hour
      String period = 'Morning';
      try {
        final hour = int.parse(slot.startTime.split(':')[0]);
        if (hour >= 12 && hour < 16) {
          period = 'Afternoon';
        } else if (hour >= 16) {
          period = 'Evening';
        }
      } catch (_) {}

      return HealerAvailability(
        date: dateStr,
        day: dayStr,
        isAvailable: slot.availabilityType == 1,
        periods: [period],
      );
    }).toList();

    return HealerModel(
      id: item.id,
      name: item.healerName,
      imageUrl: item.photo ?? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
      specialization: 'Healing Expert', // Placeholder since API lacks it here
      experienceYears: item.experienceYears ?? 0,
      rating: 0.0, // Placeholder
      reviewsCount: 0, // Placeholder
      isAvailableNow: availability.any((a) => a.isAvailable),
      feesPerMin: minPrice,
      availability: availability,
      rawSlots: item.sessionSlots,
      sessionPricing: const [],
      liveCounsellingPricing: item.liveCounselling,
    );
  }

  factory HealerModel.fromDetailsApi(HealerDetailsResponseModel item) {
    int minPrice = 0;
    if (item.liveCounsellingPricing.isNotEmpty) {
      minPrice = item.liveCounsellingPricing
          .map((c) => c.pricePerMinute)
          .reduce((a, b) => a < b ? a : b);
    }

    final availability = item.sessionSlots.map((slot) {
      DateTime dt;
      String dayStr = '';
      String dateStr = '';
      try {
        dt = DateTime.parse(slot.date);
        dayStr = DateFormat('E').format(dt);
        dateStr = DateFormat('MMM dd').format(dt);
      } catch (_) {}

      String period = 'Morning';
      try {
        final hour = int.parse(slot.startTime.split(':')[0]);
        if (hour >= 12 && hour < 16) {
          period = 'Afternoon';
        } else if (hour >= 16) {
          period = 'Evening';
        }
      } catch (_) {}

      return HealerAvailability(
        date: dateStr,
        day: dayStr,
        isAvailable: slot.availabilityType == 1,
        periods: [period],
      );
    }).toList();

    final education = item.certificates.map((cert) {
      return HealerEducation(
        title: cert.name,
        imagePath: 'assets/image/Layer 1 2.png',
      );
    }).toList();

    int chatPrice = 0;
    int callPrice = 0;
    int videoPrice = 0;

    for (final priceItem in item.liveCounsellingPricing) {
      if (priceItem.consultationType == 0) chatPrice = priceItem.pricePerMinute;
      if (priceItem.consultationType == 1) callPrice = priceItem.pricePerMinute;
      if (priceItem.consultationType == 2) videoPrice = priceItem.pricePerMinute;
    }

    if (chatPrice == 0) chatPrice = 30;
    if (callPrice == 0) callPrice = 30;
    if (videoPrice == 0) videoPrice = 30;

    final services = HealerServices(
      oneToOne: HealingService(
        type: 'One-to-One Healing',
        callPrice: callPrice,
        videoPrice: videoPrice,
        chatPrice: chatPrice,
      ),
      group: HealingService(
        type: 'Group Healing',
        callPrice: callPrice,
        videoPrice: videoPrice,
        chatPrice: chatPrice,
      ),
    );

    return HealerModel(
      id: item.id,
      name: item.healerName,
      imageUrl: item.profileImage ?? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
      specialization: item.specializations.isNotEmpty ? item.specializations.first.name : 'Healing Expert',
      experienceYears: item.experienceYears ?? 0,
      rating: 4.89,
      reviewsCount: 59,
      isAvailableNow: availability.any((a) => a.isAvailable),
      feesPerMin: minPrice,
      availability: availability,
      about: item.aboutMe ?? '',
      description: item.aboutMe ?? '',
      education: education.isNotEmpty ? education : const [
        HealerEducation(title: 'Healing Certificate', imagePath: 'assets/image/Layer 1 2.png'),
      ],
      experienceDetails: item.expertise,
      services: services,
      reviews: const [
        HealerReview(
          id: 'rev1',
          userName: 'Emma',
          userImageUrl: 'assets/image/primage.png',
          comment: 'The healing experience was truly calming and supportive.',
          rating: 4.89,
          date: '3 weeks ago',
        ),
      ],
      rawSlots: item.sessionSlots,
      sessionPricing: item.sessionPricing,
      liveCounsellingPricing: item.liveCounsellingPricing,
    );
  }

  factory HealerModel.dummy() {
    return const HealerModel(
      id: 'dummy',
      name: 'Dr. William',
      imageUrl: 'assets/image/primage.png',
      specialization: 'Astrologer',
      experienceYears: 11,
      rating: 4.89,
      reviewsCount: 59,
      isAvailableNow: true,
      feesPerMin: 120,
      availability: [
        HealerAvailability(
          day: 'Mon',
          periods: ['Morning', 'Evening'],
          date: 'Mar 01',
          isAvailable: true,
        ),
      ],
      description: 'A dedicated learning space designed to help individuals understand healing practices.',
      about: 'Dr. William is a dedicated astrologer...',
    );
  }

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
    rawSlots,
    sessionPricing,
    liveCounsellingPricing,
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
