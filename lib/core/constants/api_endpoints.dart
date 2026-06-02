class ApiEndpoints {
  static const String baseUrl = 'https://api.devhealer.hyperbeen.com/api/v1';

  static const String sendOtp = '$baseUrl/Patient/send-otp';
  static const String verifyOtp = '$baseUrl/Patient/verify-otp';

  static String saveProfile(String patientId) => '$baseUrl/Patient/profile/$patientId';
  
  static const String categorySpecializations = '$baseUrl/Patient/category-specializations';
  static String savePreference(String patientId) => '$baseUrl/Patient/preference/$patientId';

  static const String approvedHealers = '$baseUrl/Healer/approved-healers';
  static String approvedHealerDetails(String healerId) =>
      '$baseUrl/Healer/approved-healers/$healerId';

  static const String walletPaymentIntent = '$baseUrl/wallet/payment-intent';
  static const String walletBalance = '$baseUrl/wallet/balance';
  static const String walletTransactions = '$baseUrl/wallet/transactions';

  static const String createBooking = '$baseUrl/booking';

  static String myBookings({bool isHealer = false}) =>
      '$baseUrl/booking/my?isHealer=$isHealer';

  static String bookingDetail(String bookingId) =>
      '$baseUrl/booking/$bookingId';
}
