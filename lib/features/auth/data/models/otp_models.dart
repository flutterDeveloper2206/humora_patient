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

  const VerifyOtpRequest({
    required this.mobile,
    required this.countryCode,
    required this.code,
    required this.timeZone,
  });

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'countryCode': countryCode,
      'code': code,
      'timeZone': timeZone,
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
