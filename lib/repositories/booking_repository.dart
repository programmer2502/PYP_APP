import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingRepository {
  final BookingService _service;

  BookingRepository({BookingService? service})
      : _service = service ?? BookingService();

  Stream<List<BookingModel>> getCustomerBookings(String customerId) {
    return _service.streamCustomerBookings(customerId);
  }

  Stream<List<BookingModel>> getPhotographerRequests(String photographerId) {
    return _service.streamPhotographerRequests(photographerId);
  }

  Future<String> createBooking(BookingModel booking) {
    return _service.createBooking(booking);
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus currentStatus,
    required BookingStatus newStatus,
  }) {
    return _service.updateBookingStatus(
      bookingId: bookingId,
      currentStatus: currentStatus,
      newStatus: newStatus,
    );
  }
}
