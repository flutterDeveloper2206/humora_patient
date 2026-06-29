import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyToken = 'auth_token';
  static const String _keyPatientId = 'patient_id';
  static const String _keyCurrencyId = 'currency_id';
  static const String _keyUserProfileJson = 'user_profile_json';
  static const String _keyFcmToken = 'fcm_token';
  static const String _keyLastSyncedFcmToken = 'last_synced_fcm_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyPatientId);
    await prefs.remove(_keyCurrencyId);
    await prefs.remove(_keyUserProfileJson);
    await prefs.remove(_keyFcmToken);
    await prefs.remove(_keyLastSyncedFcmToken);
    await prefs.remove(_keyVoipToken);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> savePatientId(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPatientId, patientId);
  }

  static Future<String?> getPatientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPatientId);
  }

  static Future<void> saveCurrencyId(String currencyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrencyId, currencyId);
  }

  static Future<String?> getCurrencyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrencyId);
  }

  static Future<void> saveUserProfileJson(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserProfileJson, json);
  }

  static Future<String?> getUserProfileJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserProfileJson);
  }

  static const String _keyVoipToken = 'voip_token';

  static Future<void> saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFcmToken, token);
  }

  static Future<void> saveVoipToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyVoipToken, token);
  }

  static Future<String?> getVoipToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVoipToken);
  }

  static Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFcmToken);
  }

  static Future<void> saveLastSyncedFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSyncedFcmToken, token);
  }

  static Future<String?> getLastSyncedFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastSyncedFcmToken);
  }

  static Future<void> clearFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFcmToken);
    await prefs.remove(_keyLastSyncedFcmToken);
  }

  static Future<void> clearLastSyncedFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastSyncedFcmToken);
  }
}
