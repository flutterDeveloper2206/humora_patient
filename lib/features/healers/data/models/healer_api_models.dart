class ApprovedHealersRequestModel {
  final int skip;
  final int take;
  final String searchValue;
  final List<String> languageIds;
  final List<String> specializationIds;
  final List<int> consultationTypes;

  ApprovedHealersRequestModel({
    this.skip = 0,
    this.take = 20,
    this.searchValue = '',
    this.languageIds = const [],
    this.specializationIds = const [],
    this.consultationTypes = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'skip': skip,
      'take': take,
      'searchValue': searchValue,
      if (languageIds.isNotEmpty) 'languageIds': languageIds,
      if (specializationIds.isNotEmpty) 'specializationIds': specializationIds,
      if (consultationTypes.isNotEmpty) 'consultationTypes': consultationTypes,
    };
  }
}

class ApprovedHealersResponseModel {
  final int skip;
  final int take;
  final int totalCount;
  final String? searchValue;
  final List<ApprovedHealerItem> items;

  ApprovedHealersResponseModel({
    required this.skip,
    required this.take,
    required this.totalCount,
    this.searchValue,
    required this.items,
  });

  factory ApprovedHealersResponseModel.fromJson(Map<String, dynamic> json) {
    return ApprovedHealersResponseModel(
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      take: (json['take'] as num?)?.toInt() ?? 20,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      searchValue: json['searchValue'] as String?,
      items:
          (json['items'] as List?)
              ?.map(
                (e) => ApprovedHealerItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class ApprovedHealerItem {
  final String id;
  final String healerName;
  final String? photo;
  final int? experienceYears;
  final String? liveStatus;
  final List<LiveCounsellingItem> liveCounselling;
  final List<SessionSlotItem> sessionSlots;

  ApprovedHealerItem({
    required this.id,
    required this.healerName,
    this.photo,
    this.experienceYears,
    this.liveStatus,
    required this.liveCounselling,
    required this.sessionSlots,
  });

  bool get isLiveOnline => liveStatus == 'Online';
  bool get isLiveBusy => liveStatus == 'Busy';

  factory ApprovedHealerItem.fromJson(Map<String, dynamic> json) {
    return ApprovedHealerItem(
      id: json['id'] ?? '',
      healerName: json['healerName'] ?? '',
      photo: json['photo'] as String?,
      experienceYears: (json['experienceYears'] as num?)?.toInt(),
      liveStatus: _parseLiveStatus(json['liveStatus']),
      liveCounselling:
          (json['liveCounselling'] as List?)
              ?.map(
                (e) => LiveCounsellingItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      sessionSlots:
          (json['sessionSlots'] as List?)
              ?.map((e) => SessionSlotItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LiveCounsellingItem {
  final String currencyId;
  final String currency;
  final int consultationType;
  final int pricePerMinute;
  final bool isFreeMinutesEnabled;
  final int freeMinutes;

  LiveCounsellingItem({
    required this.currencyId,
    required this.currency,
    required this.consultationType,
    required this.pricePerMinute,
    required this.isFreeMinutesEnabled,
    required this.freeMinutes,
  });

  factory LiveCounsellingItem.fromJson(Map<String, dynamic> json) {
    return LiveCounsellingItem(
      currencyId: json['currencyId'] ?? '',
      currency: json['currency'] ?? '',
      consultationType: (json['consultationType'] as num?)?.toInt() ?? 0,
      pricePerMinute: (json['pricePerMinute'] as num?)?.toInt() ?? 0,
      isFreeMinutesEnabled: json['isFreeMinutesEnabled'] ?? false,
      freeMinutes: (json['freeMinutes'] as num?)?.toInt() ?? 0,
    );
  }
}

class SessionSlotItem {
  final String id;
  final int availabilityType;
  final int sessionType;
  final String date;
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  SessionSlotItem({
    required this.id,
    required this.availabilityType,
    required this.sessionType,
    required this.date,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory SessionSlotItem.fromJson(Map<String, dynamic> json) {
    return SessionSlotItem(
      id: json['id']?.toString() ?? '',
      availabilityType: _parseInt(json['availabilityType']),
      sessionType: _parseInt(json['sessionType']),
      date: json['date']?.toString() ?? '',
      dayOfWeek: _parseInt(json['dayOfWeek']),
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
    );
  }
}

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

class HealerDetailsResponseModel {
  final String id;
  final String firstName;
  final String lastName;
  final String healerName;
  final String email;
  final String mobile;
  final String countryCode;
  final String? birthDate;
  final String? profileImage;
  final int gender;
  final String? aboutMe;
  final int? experienceYears;
  final int onboardingStatus;
  final String? address;
  final List<LanguageItem> languages;
  final List<String> expertise;
  final List<HealerSpecializationItem> specializations;
  final List<CertificateItem> certificates;
  final List<LiveCounsellingItem> liveCounsellingPricing;
  final List<SessionPricingItem> sessionPricing;
  final List<SessionSlotItem> sessionSlots;
  final String? liveStatus;

  HealerDetailsResponseModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.healerName,
    required this.email,
    required this.mobile,
    required this.countryCode,
    this.birthDate,
    this.profileImage,
    required this.gender,
    this.aboutMe,
    this.experienceYears,
    required this.onboardingStatus,
    this.address,
    required this.languages,
    required this.expertise,
    required this.specializations,
    required this.certificates,
    required this.liveCounsellingPricing,
    required this.sessionPricing,
    required this.sessionSlots,
    this.liveStatus,
  });

  factory HealerDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return HealerDetailsResponseModel(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      healerName: json['healerName'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      countryCode: json['countryCode'] ?? '',
      birthDate: json['birthDate'] as String?,
      profileImage: json['profileImage'] as String?,
      gender: (json['gender'] as num?)?.toInt() ?? 0,
      aboutMe: json['aboutMe'] as String?,
      experienceYears: (json['experienceYears'] as num?)?.toInt(),
      onboardingStatus: (json['onboardingStatus'] as num?)?.toInt() ?? 0,
      address: json['address'] as String?,
      languages:
          (json['languages'] as List?)
              ?.map((e) => LanguageItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      expertise:
          (json['expertise'] as List?)?.map((e) => e.toString()).toList() ?? [],
      specializations:
          (json['specializations'] as List?)
              ?.map(
                (e) => HealerSpecializationItem.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      certificates:
          (json['certificates'] as List?)
              ?.map((e) => CertificateItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      liveCounsellingPricing:
          (json['liveCounsellingPricing'] as List?)
              ?.map(
                (e) => LiveCounsellingItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      sessionPricing:
          (json['sessionPricing'] as List?)
              ?.map(
                (e) => SessionPricingItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      sessionSlots:
          (json['sessionSlots'] as List?)
              ?.map((e) => SessionSlotItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      liveStatus: _parseLiveStatus(json['liveStatus']),
    );
  }
}

class LanguageItem {
  final String id;
  final String name;

  LanguageItem({required this.id, required this.name});

  factory LanguageItem.fromJson(Map<String, dynamic> json) {
    return LanguageItem(id: json['id'] ?? '', name: json['name'] ?? '');
  }
}

class HealerSpecializationItem {
  final String id;
  final String name;
  final String categoryId;
  final String categoryName;

  HealerSpecializationItem({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
  });

  factory HealerSpecializationItem.fromJson(Map<String, dynamic> json) {
    return HealerSpecializationItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
    );
  }
}

class CertificateItem {
  final String id;
  final String name;

  CertificateItem({required this.id, required this.name});

  factory CertificateItem.fromJson(Map<String, dynamic> json) {
    return CertificateItem(id: json['id'] ?? '', name: json['name'] ?? '');
  }
}

class SessionPricingItem {
  final String currencyId;
  final String currency;
  final int sessionType;
  final int price;
  final int durationMinutes;
  final int maxParticipants;

  SessionPricingItem({
    required this.currencyId,
    required this.currency,
    required this.sessionType,
    required this.price,
    required this.durationMinutes,
    required this.maxParticipants,
  });

  factory SessionPricingItem.fromJson(Map<String, dynamic> json) {
    return SessionPricingItem(
      currencyId: json['currencyId'] ?? '',
      currency: json['currency'] ?? '',
      sessionType: (json['sessionType'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toInt() ?? 0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 0,
    );
  }
}

String? _parseLiveStatus(dynamic value) {
  if (value == null) return null;
  if (value is num) {
    switch (value.toInt()) {
      case 1:
        return 'Online';
      case 2:
        return 'Busy';
      default:
        return 'Offline';
    }
  }
  final text = value.toString();
  if (text == '0') return 'Offline';
  if (text == '1') return 'Online';
  if (text == '2') return 'Busy';
  return text;
}
