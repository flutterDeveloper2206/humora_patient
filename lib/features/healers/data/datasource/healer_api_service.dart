import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/session_manager.dart';
import '../models/healer_api_models.dart';
import '../models/healer_model.dart';

class HealerApiService {
  Future<List<HealerModel>> fetchApprovedHealers(
      ApprovedHealersRequestModel request) async {
    try {
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final url = Uri.parse(ApiEndpoints.approvedHealers);
      log('Fetching approved healers from: $url');
      log('Request payload: ${jsonEncode(request.toJson())}');

      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      log('Approved Healers Response: ${response.statusCode}');
      log('Approved Healers Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final responseModel = ApprovedHealersResponseModel.fromJson(decoded);

        // Map ApprovedHealerItem to HealerModel for the UI
        return responseModel.items.map((item) {
          return HealerModel.fromApi(item);
        }).toList();
      } else {
        throw Exception('Failed to fetch healers: ${response.body}');
      }
    } catch (e) {
      log('Error in fetchApprovedHealers: $e');
      throw Exception('Failed to fetch healers: $e');
    }
  }

  Future<HealerModel> fetchHealerDetails(String healerId) async {
    try {
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final url = Uri.parse(ApiEndpoints.approvedHealerDetails(healerId));
      log('Fetching approved healer details from: $url');

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      log('Approved Healer Details Response: ${response.statusCode}');
      log('Approved Healer Details Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final responseModel = HealerDetailsResponseModel.fromJson(decoded);

        // Map HealerDetailsResponseModel to HealerModel for the UI
        return HealerModel.fromDetailsApi(responseModel);
      } else {
        throw Exception('Failed to fetch healer details: ${response.body}');
      }
    } catch (e) {
      log('Error in fetchHealerDetails: $e');
      throw Exception('Failed to fetch healer details: $e');
    }
  }
}
