class SendOtpRequest {
  final String mobile;
  final String countryCode;

  const SendOtpRequest({
    required this.mobile,
    required this.countryCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'countryCode': countryCode,
    };
  }
}

class SendOtpResponse {
  final String message;

  const SendOtpResponse({
    required this.message,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      message: json['message'] as String? ?? '',
    );
  }
}

class VerifyOtpRequest {
  final String mobile;
  final String countryCode;
  final String code;
  final String timeZone;
  final String? fcmToken;

  const VerifyOtpRequest({
    required this.mobile,
    required this.countryCode,
    required this.code,
    required this.timeZone,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'countryCode': countryCode,
      'code': code,
      'timeZone': timeZone,
      if (fcmToken != null && fcmToken!.isNotEmpty) 'fcmToken': fcmToken,
    };
  }
}

class VerifyOtpResponse {
  final String token;
  final String userId;
  final String patientId;
  final String countryId;
  final String currencyId;
  final int onboardingStep;

  const VerifyOtpResponse({
    required this.token,
    required this.userId,
    required this.patientId,
    required this.countryId,
    required this.currencyId,
    required this.onboardingStep,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      token: json['token'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      countryId: json['countryId'] as String? ?? '',
      currencyId: json['currencyId'] as String? ?? '',
      onboardingStep: json['onboardingStep'] as int? ?? 1,
    );
  }
}

class VerifyTokenUserData {
  final String patientId;
  final String userId;
  final String countryId;
  final String currencyId;
  final int onboardingStep;

  const VerifyTokenUserData({
    required this.patientId,
    required this.userId,
    required this.countryId,
    required this.currencyId,
    required this.onboardingStep,
  });

  factory VerifyTokenUserData.fromJson(Map<String, dynamic> json) {
    return VerifyTokenUserData(
      patientId: json['patientId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      countryId: json['countryId'] as String? ?? '',
      currencyId: json['currencyId'] as String? ?? '',
      onboardingStep: json['onboardingStep'] as int? ?? 1,
    );
  }
}

class VerifyTokenResponse {
  final String message;
  final VerifyTokenUserData userData;

  const VerifyTokenResponse({
    required this.message,
    required this.userData,
  });

  factory VerifyTokenResponse.fromJson(Map<String, dynamic> json) {
    final rawUserData = json['userData'];
    return VerifyTokenResponse(
      message: json['message'] as String? ?? '',
      userData: rawUserData is Map<String, dynamic>
          ? VerifyTokenUserData.fromJson(rawUserData)
          : const VerifyTokenUserData(
              patientId: '',
              userId: '',
              countryId: '',
              currencyId: '',
              onboardingStep: 1,
            ),
    );
  }
}
