import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyToken = 'auth_token';
  static const String _keyPatientId = 'patient_id';
  static const String _keyCurrencyId = 'currency_id';

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
}
