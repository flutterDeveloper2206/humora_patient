import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/app_http_client.dart';
import '../../../../core/utils/session_manager.dart';
import '../models/healer_calendar_models.dart';

class HealerCalendarApiService {
  final http.Client _client;

  HealerCalendarApiService({http.Client? client})
      : _client = client ?? AppHttpClient.instance;

  Future<String> _requireToken() async {
    final token = await SessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }
    return token;
  }

  Map<String, dynamic> _parseResponse(http.Response response, Uri url) {
    developer.log('--- API RESPONSE ---', name: 'HealerCalendarApiService');
    developer.log('URL: $url', name: 'HealerCalendarApiService');
    developer.log('Status: ${response.statusCode}', name: 'HealerCalendarApiService');
    developer.log('Body: ${response.body}', name: 'HealerCalendarApiService');

    dynamic responseData;
    try {
      responseData =
          response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Server error (${response.statusCode}): Invalid response format.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseData is Map<String, dynamic>) return responseData;
      throw Exception('Unexpected calendar response format.');
    }

    var errorMessage = 'Request failed with status ${response.statusCode}';
    if (responseData is Map<String, dynamic>) {
      if (responseData['message'] != null) {
        errorMessage = responseData['message'].toString();
      } else if (responseData['error'] != null) {
        errorMessage = responseData['error'].toString();
      } else if (responseData['errors'] != null) {
        final errors = responseData['errors'];
        if (errors is List) {
          errorMessage = errors.map((e) => e.toString()).join(', ');
        }
      }
    }
    throw Exception(errorMessage);
  }

  Future<HealerCalendarResponse> fetchCalendar() async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.healerCalendar);

    developer.log('--- API REQUEST ---', name: 'HealerCalendarApiService');
    developer.log('GET $url', name: 'HealerCalendarApiService');

    final response = await _client.get(
      url,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _parseResponse(response, url);
    return HealerCalendarResponse.fromJson(data);
  }
}
