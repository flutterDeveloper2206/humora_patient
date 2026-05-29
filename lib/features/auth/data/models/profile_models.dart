class SaveProfileRequest {
  final String firstName;
  final String lastName;
  final String email;
  final int gender; // 0: Male, 1: Female, 2: Other
  final String birthDate;

  const SaveProfileRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.birthDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'gender': gender,
      'birthDate': birthDate,
    };
  }
}

class SaveProfileResponse {
  final String message;
  final SaveProfileData? data;

  const SaveProfileResponse({
    required this.message,
    this.data,
  });

  factory SaveProfileResponse.fromJson(Map<String, dynamic> json) {
    return SaveProfileResponse(
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? SaveProfileData.fromJson(json['data']) : null,
    );
  }
}

class SaveProfileData {
  final String patientId;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String countryCode;
  final int gender;
  final String birthDate;

  const SaveProfileData({
    required this.patientId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.countryCode,
    required this.gender,
    required this.birthDate,
  });

  factory SaveProfileData.fromJson(Map<String, dynamic> json) {
    return SaveProfileData(
      patientId: json['patientId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
      gender: json['gender'] as int? ?? 0,
      birthDate: json['birthDate'] as String? ?? '',
    );
  }
}
