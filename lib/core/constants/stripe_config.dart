/// Stripe test configuration for wallet top-up.
class StripeConfig {
  static const String publishableKey =
      'pk_test_51TOMwkC4xf2vY9S8aAOFj3aZoXow8KgL3ynvUrdIAv43VC2BrjxhFo9nbp04DX9J6a1aybIF0odl6glZFETOYSFZ0043WEsmRj';

  /// iOS URL scheme — must match `CFBundleURLSchemes` in ios/Runner/Info.plist.
  static const String urlScheme = 'humorapatient';

  /// iOS 3DS / redirect return URL (scheme + safepay path per Stripe SDK).
  static const String returnUrl = '$urlScheme://safepay';

  /// Default INR currency id from backend.
  static const String defaultCurrencyId =
      '019df1b3-a31d-71fe-8d56-c7a76c7b8197';

  /// Default minimum for INR; use [WalletBalanceResponse.minimumTopUpAmount] per wallet currency.
  static const double minimumTopUpAmountInr = 50;
  static const double minimumTopUpAmountOther = 0.5;
}
