class ApiEndpoints {
  static const String baseUrl = 'https://api.devhealer.hyperbeen.com/api/v1';
  static const String origin = 'https://api.devhealer.hyperbeen.com';

  static const String liveHubUrl = '$origin/hubs/live';
  static const String chatHubUrl = '$origin/hubs/chat';

  static const String sendOtp = '$baseUrl/Patient/send-otp';
  static const String verifyOtp = '$baseUrl/Patient/verify-otp';

  static String saveProfile(String patientId) =>
      '$baseUrl/Patient/profile/$patientId';

  static const String categorySpecializations =
      '$baseUrl/Patient/category-specializations';
  static String savePreference(String patientId) =>
      '$baseUrl/Patient/preference/$patientId';

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

  static String scheduledAgoraToken(String bookingId) =>
      '$baseUrl/booking/$bookingId/agora-token';

  static String bookingAgoraJoin(String bookingId) =>
      '$baseUrl/booking/$bookingId/join';

  static const String agoraToken = '$baseUrl/agora/token';
  static const String agoraJoin = '$baseUrl/agora/join';
  static const String agoraLeave = '$baseUrl/agora/leave';
  static const String agoraReconnect = '$baseUrl/agora/reconnect';
  static String agoraState(String bookingId) => '$baseUrl/agora/$bookingId/state';

  // Live consultation
  static const String liveRequest = '$baseUrl/live/request';
  static String liveRequestStatus(String requestId) =>
      '$baseUrl/live/request/$requestId';
  static String liveSession(String bookingId) =>
      '$baseUrl/live/session/$bookingId';
  static const String liveEnd = '$baseUrl/live/end';
  static String liveHistory({int page = 1, int pageSize = 20}) =>
      '$baseUrl/live/history?page=$page&pageSize=$pageSize';

  // Chat
  static String chatAccess(String bookingId) =>
      '$baseUrl/chat/access/$bookingId';
  static String chatHistory(String bookingId, {int page = 1, int pageSize = 50}) =>
      '$baseUrl/chat/history/$bookingId?page=$page&pageSize=$pageSize';
  static const String chatConversations = '$baseUrl/chat/conversations';
  static String chatConversation(String bookingId) =>
      '$baseUrl/chat/conversation/$bookingId';
  static String chatSearch(String bookingId, String query) =>
      '$baseUrl/chat/search/$bookingId?q=${Uri.encodeQueryComponent(query)}';
  static const String chatSend = '$baseUrl/chat/send';
  static const String chatEditMessage = '$baseUrl/chat/message/edit';
  static String chatDeleteMessage(String messageId) =>
      '$baseUrl/chat/message/$messageId';
}
