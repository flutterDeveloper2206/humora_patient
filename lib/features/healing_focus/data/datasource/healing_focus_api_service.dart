import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../models/healing_focus_models.dart';

class HealingFocusApiService {
  final http.Client _client;

  HealingFocusApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, dynamic> _parseResponse(http.Response response, Uri url) {
    developer.log('--- API RESPONSE ---', name: 'HealingFocusApiService');
    developer.log('URL: $url', name: 'HealingFocusApiService');
    developer.log(
      'Status Code: ${response.statusCode}',
      name: 'HealingFocusApiService',
    );
    developer.log('Response Body: ${response.body}', name: 'HealingFocusApiService');

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

  Future<CategorySpecializationsResponse> getCategorySpecializations(String token) async {
    final url = Uri.parse(ApiEndpoints.categorySpecializations);
    final headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
    };

    developer.log('--- API REQUEST ---', name: 'HealingFocusApiService');
    developer.log('URL: $url', name: 'HealingFocusApiService');
    developer.log('Headers: $headers', name: 'HealingFocusApiService');

    try {
      final response = await _client.get(url, headers: headers);
      final responseData = _parseResponse(response, url);
      return CategorySpecializationsResponse.fromJson(responseData);
    } catch (e) {
      developer.log('API Error: $e', name: 'HealingFocusApiService', error: e);
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<SavePreferenceResponse> savePreference(
      SavePreferenceRequest request, String token, String patientId) async {
    final url = Uri.parse(ApiEndpoints.savePreference(patientId));
    final headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
    final body = jsonEncode(request.toJson());

    developer.log('--- API REQUEST ---', name: 'HealingFocusApiService');
    developer.log('URL: $url', name: 'HealingFocusApiService');
    developer.log('Headers: $headers', name: 'HealingFocusApiService');
    developer.log('Body: $body', name: 'HealingFocusApiService');

    try {
      final response = await _client.post(url, headers: headers, body: body);
      final responseData = _parseResponse(response, url);
      return SavePreferenceResponse.fromJson(responseData);
    } catch (e) {
      developer.log('API Error: $e', name: 'HealingFocusApiService', error: e);
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
