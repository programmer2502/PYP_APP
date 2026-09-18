import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exceptions.dart';
import '../models/booking_model.dart';
import 'firestore_service.dart';

class BookingService {
  final FirestoreService _firestoreService;

  BookingService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<BookingModel>> streamCustomerBookings(String customerId) {
    if (!_firestoreService.isReady) {
      return Stream.value([]);
    }

    return _firestoreService
        .collection(FirestoreCollections.bookings)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<BookingModel>> streamPhotographerRequests(String photographerId) {
    if (!_firestoreService.isReady) {
      return Stream.value([]);
    }

    return _firestoreService
        .collection(FirestoreCollections.bookings)
        .where('photographerId', isEqualTo: photographerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<String> createBooking(BookingModel booking) async {
    if (!_firestoreService.isReady) {
      throw const FirestoreException('Firestore is not initialized.');
    }

    // Backend-safe validation: prevent double-booking on accepted bookings
    final conflictCheck = await _firestoreService
        .collection(FirestoreCollections.bookings)
        .where('photographerId', isEqualTo: booking.photographerId)
        .where('status', isEqualTo: 'Accepted')
        .where('startTime', isEqualTo: booking.time)
        .get();

    final hasConflict = conflictCheck.docs.any((doc) {
      final data = doc.data();
      final date = data['eventDate'] is Timestamp
          ? (data['eventDate'] as Timestamp).toDate()
          : (data['date'] is Timestamp
              ? (data['date'] as Timestamp).toDate()
              : null);
      if (date == null) return false;
      return date.year == booking.date.year &&
          date.month == booking.date.month &&
          date.day == booking.date.day;
    });

    if (hasConflict) {
      throw const BookingConflictException(
        'This photographer is already booked for the selected date and time slot.',
      );
    }

    try {
      final docRef = await _firestoreService
          .collection(FirestoreCollections.bookings)
          .add(booking.toMap());
      return docRef.id;
    } catch (e) {
      throw FirestoreException('Failed to create booking: $e');
    }
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus currentStatus,
    required BookingStatus newStatus,
  }) async {
    if (!currentStatus.canTransitionTo(newStatus)) {
      throw AppException(
        'Invalid status transition from ${currentStatus.displayName} to ${newStatus.displayName}',
      );
    }

    if (!_firestoreService.isReady) return;

    try {
      await _firestoreService
          .collection(FirestoreCollections.bookings)
          .doc(bookingId)
          .update({
        'status': newStatus.displayName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Failed to update booking status: $e');
    }
  }
}
