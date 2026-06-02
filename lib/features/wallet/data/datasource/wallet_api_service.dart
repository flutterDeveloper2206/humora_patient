import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/app_http_client.dart';
import '../../../../core/utils/session_manager.dart';
import '../models/wallet_models.dart';

class WalletApiService {
  final http.Client _client;

  WalletApiService({http.Client? client})
      : _client = client ?? AppHttpClient.instance;

  Future<String> _requireToken() async {
    final token = await SessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }
    return token;
  }

  Map<String, dynamic> _parseResponse(http.Response response, Uri url) {
    developer.log('--- API RESPONSE ---', name: 'WalletApiService');
    developer.log('URL: $url', name: 'WalletApiService');
    developer.log('Status: ${response.statusCode}', name: 'WalletApiService');
    developer.log('Body: ${response.body}', name: 'WalletApiService');

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
    }

    String errorMessage = 'Request failed with status ${response.statusCode}';
    if (responseData is Map<String, dynamic>) {
      if (responseData['message'] != null) {
        errorMessage = responseData['message'].toString();
      } else if (responseData['error'] != null) {
        errorMessage = responseData['error'].toString();
      } else if (responseData['errors'] != null) {
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

  Future<PaymentIntentResponse> createPaymentIntent(
    PaymentIntentRequest request,
  ) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.walletPaymentIntent);
    final headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode(request.toJson());

    developer.log('--- API REQUEST ---', name: 'WalletApiService');
    developer.log('POST $url', name: 'WalletApiService');
    developer.log('Body: $body', name: 'WalletApiService');

    final response = await _client.post(url, headers: headers, body: body);
    final data = _parseResponse(response, url);
    return PaymentIntentResponse.fromJson(data);
  }

  Future<WalletBalanceResponse> getBalance() async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.walletBalance);
    final headers = {'accept': '*/*', 'Authorization': 'Bearer $token'};

    developer.log('GET $url', name: 'WalletApiService');

    final response = await _client.get(url, headers: headers);
    final data = _parseResponse(response, url);
    return WalletBalanceResponse.fromJson(data);
  }

  Future<WalletTransactionsResponse> getTransactions({
    int skip = 0,
    int take = 20,
    int? transactionType,
    int? status,
    int? source,
    String? from,
    String? to,
    String? search,
  }) async {
    final token = await _requireToken();
    final query = <String, String>{
      'skip': skip.toString(),
      'take': take.toString(),
      if (transactionType != null) 'transactionType': '$transactionType',
      if (status != null) 'status': '$status',
      if (source != null) 'source': '$source',
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final url = Uri.parse(
      ApiEndpoints.walletTransactions,
    ).replace(queryParameters: query);
    final headers = {'accept': '*/*', 'Authorization': 'Bearer $token'};

    developer.log('GET $url', name: 'WalletApiService');

    final response = await _client.get(url, headers: headers);
    final data = _parseResponse(response, url);
    return WalletTransactionsResponse.fromJson(data);
  }
}
