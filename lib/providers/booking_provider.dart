import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../repositories/booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<BookingModel> _customerBookings = [];
  List<BookingModel> _photographerRequests = [];
  StreamSubscription<List<BookingModel>>? _customerSubscription;
  StreamSubscription<List<BookingModel>>? _photographerSubscription;

  BookingProvider({BookingRepository? repository})
      : _repository = repository ?? BookingRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BookingModel> get customerBookings => _customerBookings;
  List<BookingModel> get photographerRequests => _photographerRequests;

  void streamCustomerBookings(String customerId) {
    _customerSubscription?.cancel();
    _customerSubscription = _repository.getCustomerBookings(customerId).listen(
      (items) {
        _customerBookings = items;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  void streamPhotographerRequests(String photographerId) {
    _photographerSubscription?.cancel();
    _photographerSubscription = _repository.getPhotographerRequests(photographerId).listen(
      (items) {
        _photographerRequests = items;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  Future<String?> createBooking(BookingModel booking) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final bookingId = await _repository.createBooking(booking);
      final createdBooking = booking.copyWith(id: bookingId);
      _customerBookings.insert(0, createdBooking);
      _isLoading = false;
      notifyListeners();
      return bookingId;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStatus({
    required BookingModel booking,
    required BookingStatus newStatus,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateBookingStatus(
        bookingId: booking.id,
        currentStatus: booking.bookingStatus,
        newStatus: newStatus,
      );

      booking.status = newStatus.displayName;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _customerSubscription?.cancel();
    _photographerSubscription?.cancel();
    super.dispose();
  }
}
