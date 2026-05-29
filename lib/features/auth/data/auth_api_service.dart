import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints.dart';
import 'models/otp_models.dart';
import 'models/profile_models.dart';

class AuthApiService {
  final http.Client _client;

  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Helper to print logs and parse standard/error HTTP responses
  Map<String, dynamic> _parseResponse(http.Response response, Uri url) {
    developer.log('--- API RESPONSE ---', name: 'AuthApiService');
    developer.log('URL: $url', name: 'AuthApiService');
    developer.log(
      'Status Code: ${response.statusCode}',
      name: 'AuthApiService',
    );
    developer.log('Response Body: ${response.body}', name: 'AuthApiService');

    dynamic responseData;
    try {
      responseData = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Server error (${response.statusCode}): Invalid response format.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }
      throw Exception('Invalid response structure from server.');
    } else {
      String errorMessage = 'Request failed with status ${response.statusCode}';
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('message') &&
            responseData['message'] != null) {
          errorMessage = responseData['message'].toString();
        } else if (responseData.containsKey('error') &&
            responseData['error'] != null) {
          errorMessage = responseData['error'].toString();
        } else if (responseData.containsKey('errors') &&
            responseData['errors'] != null) {
          final errors = responseData['errors'];
          if (errors is List) {
            errorMessage = errors.join(', ');
          } else if (errors is Map) {
            errorMessage = errors.values
                .map((v) => v is List ? v.join(', ') : v.toString())
                .join(', ');
          } else {
            errorMessage = errors.toString();
          }
        }
      }
      throw Exception(errorMessage);
    }
  }

  /// Sends OTP to the patient's mobile number
  Future<SendOtpResponse> sendOtp(SendOtpRequest request) async {
    final url = Uri.parse(ApiEndpoints.sendOtp);
    final headers = {'accept': '*/*', 'Content-Type': 'application/json'};
    final body = jsonEncode(request.toJson());

    developer.log('--- API REQUEST ---', name: 'AuthApiService');
    developer.log('URL: $url', name: 'AuthApiService');
    developer.log('Headers: $headers', name: 'AuthApiService');
    developer.log('Body: $body', name: 'AuthApiService');

    try {
      final response = await _client.post(url, headers: headers, body: body);
      final responseData = _parseResponse(response, url);
      return SendOtpResponse.fromJson(responseData);
    } catch (e) {
      developer.log('API Error: $e', name: 'AuthApiService', error: e);
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Verifies OTP and returns user authentication data
  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    final url = Uri.parse(ApiEndpoints.verifyOtp);
    final headers = {'accept': '*/*', 'Content-Type': 'application/json'};
    final body = jsonEncode(request.toJson());

    developer.log('--- API REQUEST ---', name: 'AuthApiService');
    developer.log('URL: $url', name: 'AuthApiService');
    developer.log('Headers: $headers', name: 'AuthApiService');
    developer.log('Body: $body', name: 'AuthApiService');

    try {
      final response = await _client.post(url, headers: headers, body: body);
      final responseData = _parseResponse(response, url);
      return VerifyOtpResponse.fromJson(responseData);
    } catch (e) {
      developer.log('API Error: $e', name: 'AuthApiService', error: e);
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Saves patient profile data
  Future<SaveProfileResponse> saveProfile(
      SaveProfileRequest request, String token, String patientId) async {
    final url = Uri.parse(ApiEndpoints.saveProfile(patientId));
    final headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
    final body = jsonEncode(request.toJson());

    developer.log('--- API REQUEST ---', name: 'AuthApiService');
    developer.log('URL: $url', name: 'AuthApiService');
    developer.log('Headers: $headers', name: 'AuthApiService');
    developer.log('Body: $body', name: 'AuthApiService');

    try {
      final response = await _client.post(url, headers: headers, body: body);
      final responseData = _parseResponse(response, url);
      return SaveProfileResponse.fromJson(responseData);
    } catch (e) {
      developer.log('API Error: $e', name: 'AuthApiService', error: e);
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
