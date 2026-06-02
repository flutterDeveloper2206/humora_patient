import '../../data/datasource/my_sessions_api_service.dart';
import '../../data/models/my_booking_models.dart';

class FetchMyBookingsUseCase {
  final MySessionsApiService _apiService;

  FetchMyBookingsUseCase({MySessionsApiService? apiService})
      : _apiService = apiService ?? MySessionsApiService();

  Future<List<MyBookingModel>> call() => _apiService.fetchMyBookings();
}
