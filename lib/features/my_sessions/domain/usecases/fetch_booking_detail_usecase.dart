import '../../data/datasource/my_sessions_api_service.dart';
import '../../data/models/my_booking_models.dart';

class FetchBookingDetailUseCase {
  final MySessionsApiService _apiService;

  FetchBookingDetailUseCase({MySessionsApiService? apiService})
      : _apiService = apiService ?? MySessionsApiService();

  Future<BookingDetailModel> call(String bookingId) =>
      _apiService.fetchBookingDetail(bookingId);
}
