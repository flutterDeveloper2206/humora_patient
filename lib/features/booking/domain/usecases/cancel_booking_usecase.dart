import '../../data/datasource/booking_api_service.dart';
import '../../data/models/booking_models.dart';

class CancelBookingUseCase {
  final BookingApiService _apiService;

  CancelBookingUseCase({BookingApiService? apiService})
      : _apiService = apiService ?? BookingApiService();

  Future<CancelBookingResponse> call({
    required String bookingId,
    required String reason,
  }) {
    return _apiService.cancelBooking(
      CancelBookingRequest(bookingId: bookingId, reason: reason),
    );
  }
}
