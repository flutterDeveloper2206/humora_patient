import '../../data/datasource/booking_api_service.dart';
import '../../data/models/booking_models.dart';

class CreateBookingUseCase {
  final BookingApiService _apiService;

  CreateBookingUseCase({BookingApiService? apiService})
      : _apiService = apiService ?? BookingApiService();

  Future<CreateBookingResponse> call({
    required String healerId,
    required String slotId,
    required String bookingDate,
    required String idempotencyKey,
    int? consultationType,
  }) {
    return _apiService.createBooking(
      CreateBookingRequest(
        healerId: healerId,
        slotId: slotId,
        bookingDate: bookingDate,
        idempotencyKey: idempotencyKey,
        consultationType: consultationType,
      ),
    );
  }
}
