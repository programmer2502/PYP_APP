import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exceptions.dart';
import '../models/booking_model.dart';
import 'firestore_service.dart';

class BookingService {
  final FirestoreService _firestoreService;

  BookingService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<BookingModel>> streamCustomerBookings(dynamic identifiers) {
    if (!_firestoreService.isReady) {
      return Stream.value([]);
    }

    final List<String> cleanIds = identifiers is List<String>
        ? identifiers
        : (identifiers is String ? [identifiers] : <String>[]);

    return _firestoreService
        .collection(FirestoreCollections.bookings)
        .snapshots()
        .map((snapshot) {
          final allBookings = snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
              .toList();

          if (cleanIds.isEmpty) {
            return allBookings;
          }

          final list = allBookings
              .where((booking) => booking.matchesCustomer(cleanIds))
              .toList();

          final result = list.isNotEmpty ? list : allBookings;

          result.sort((a, b) {
            final aTime = a.createdAt ?? a.date;
            final bTime = b.createdAt ?? b.date;
            return bTime.compareTo(aTime);
          });

          return result;
        });
  }

  Stream<List<BookingModel>> streamPhotographerRequests(dynamic identifiers) {
    if (!_firestoreService.isReady) {
      return Stream.value([]);
    }

    final List<String> cleanIds = identifiers is List<String>
        ? identifiers
        : (identifiers is String ? [identifiers] : <String>[]);

    return _firestoreService
        .collection(FirestoreCollections.bookings)
        .snapshots()
        .map((snapshot) {
          final allBookings = snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
              .toList();

          if (cleanIds.isEmpty) {
            return allBookings;
          }

          final list = allBookings
              .where((booking) => booking.matchesPhotographer(cleanIds))
              .toList();

          list.sort((a, b) {
            final aTime = a.createdAt ?? a.date;
            final bTime = b.createdAt ?? b.date;
            return bTime.compareTo(aTime);
          });

          return list;
        });
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

  Future<void> updateBookingPayment({
    required String bookingId,
    required PaymentStatus paymentStatus,
    String? paymentId,
    String? orderId,
    bool? chatEnabled,
    String? conversationId,
    String? signature,
  }) async {
    if (!_firestoreService.isReady) return;

    try {
      final data = <String, dynamic>{
        'paymentStatus': paymentStatus.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (paymentId != null && paymentId.isNotEmpty) {
        data['razorpayPaymentId'] = paymentId;
      }
      if (orderId != null && orderId.isNotEmpty) {
        data['razorpayOrderId'] = orderId;
      }
      if (chatEnabled != null) {
        data['chatEnabled'] = chatEnabled;
        if (chatEnabled) {
          data['chatEnabledAt'] = FieldValue.serverTimestamp();
        }
      }
      if (conversationId != null && conversationId.isNotEmpty) {
        data['conversationId'] = conversationId;
      }
      if (signature != null && signature.isNotEmpty) {
        data['razorpaySignature'] = signature;
      }

      await _firestoreService
          .collection(FirestoreCollections.bookings)
          .doc(bookingId)
          .update(data);
    } catch (e) {
      throw FirestoreException('Failed to update booking payment: $e');
    }
  }

  Future<void> unlockBookingChat({
    required String bookingId,
    required String conversationId,
    required String paymentId,
    required String orderId,
    String? signature,
  }) async {
    if (!_firestoreService.isReady) return;

    try {
      final data = <String, dynamic>{
        'paymentStatus': PaymentStatus.paid.value,
        'chatEnabled': true,
        'chatEnabledAt': FieldValue.serverTimestamp(),
        'conversationId': conversationId,
        'razorpayPaymentId': paymentId,
        'razorpayOrderId': orderId,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (signature != null && signature.isNotEmpty) {
        data['razorpaySignature'] = signature;
      }

      await _firestoreService
          .collection(FirestoreCollections.bookings)
          .doc(bookingId)
          .update(data);
    } catch (e) {
      throw FirestoreException('Failed to unlock booking chat: $e');
    }
  }
}
