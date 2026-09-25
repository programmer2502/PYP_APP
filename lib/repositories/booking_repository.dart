import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingRepository {
  final BookingService _service;

  BookingRepository({BookingService? service})
      : _service = service ?? BookingService();

  Stream<List<BookingModel>> getCustomerBookings(dynamic customerIdOrIdentifiers) {
    return _service.streamCustomerBookings(customerIdOrIdentifiers);
  }

  Stream<List<BookingModel>> getPhotographerRequests(dynamic photographerIdOrIdentifiers) {
    return _service.streamPhotographerRequests(photographerIdOrIdentifiers);
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

  Future<void> updateBookingPayment({
    required String bookingId,
    required PaymentStatus paymentStatus,
    String? paymentId,
    String? orderId,
    bool? chatEnabled,
    String? conversationId,
    String? signature,
  }) {
    return _service.updateBookingPayment(
      bookingId: bookingId,
      paymentStatus: paymentStatus,
      paymentId: paymentId,
      orderId: orderId,
      chatEnabled: chatEnabled,
      conversationId: conversationId,
      signature: signature,
    );
  }

  Future<void> unlockBookingChat({
    required String bookingId,
    required String conversationId,
    required String paymentId,
    required String orderId,
    String? signature,
  }) {
    return _service.unlockBookingChat(
      bookingId: bookingId,
      conversationId: conversationId,
      paymentId: paymentId,
      orderId: orderId,
      signature: signature,
    );
  }
}
