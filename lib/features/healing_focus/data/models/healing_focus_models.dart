class HealingCategory {
  final String id;
  final String name;
  final String description;

  const HealingCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  factory HealingCategory.fromJson(Map<String, dynamic> json) {
    return HealingCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class HealingSpecialization {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String categoryName;
  final String icon;

  const HealingSpecialization({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.icon,
  });

  factory HealingSpecialization.fromJson(Map<String, dynamic> json) {
    return HealingSpecialization(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
    );
  }
}

class CategorySpecializationsResponse {
  final List<HealingCategory> categories;
  final List<HealingSpecialization> specializations;

  const CategorySpecializationsResponse({
    required this.categories,
    required this.specializations,
  });

  factory CategorySpecializationsResponse.fromJson(Map<String, dynamic> json) {
    return CategorySpecializationsResponse(
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => HealingCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      specializations: (json['specializations'] as List<dynamic>?)
              ?.map((e) =>
                  HealingSpecialization.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SavePreferenceRequest {
  final List<String> categoryIds;
  final List<String> specializationIds;

  const SavePreferenceRequest({
    required this.categoryIds,
    required this.specializationIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryIds': categoryIds,
      'specializationIds': specializationIds,
    };
  }
}

class SavePreferenceResponse {
  final String message;

  const SavePreferenceResponse({required this.message});

  factory SavePreferenceResponse.fromJson(Map<String, dynamic> json) {
    return SavePreferenceResponse(
      message: json['message'] as String? ?? '',
    );
  }
}
