/// Server `screen` values from notification / SessionReminder payloads.
class NotificationScreen {
  NotificationScreen._();

  static const bookingDetail = 'booking_detail';
  static const sessionActive = 'session_active';
  static const liveSession = 'live_session';
  static const liveJoin = 'live_join';
  static const home = 'home';
  static const walletEarnings = 'wallet_earnings';
  static const dashboard = 'dashboard';
  static const healerOnboarding = 'healer_onboarding';

  static String normalize(String? raw) {
    final value = raw?.trim().toLowerCase() ?? '';
    return value.isEmpty ? home : value;
  }
}
