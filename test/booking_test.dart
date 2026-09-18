import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyp_app/models/booking_model.dart';
import 'package:pyp_app/models/photographer_model.dart';
import 'package:pyp_app/providers/pyp_store.dart';
import 'package:pyp_app/screens/customer/booking_screen.dart';
import 'package:pyp_app/screens/customer/customer_bookings_content.dart';
import 'package:pyp_app/screens/photographer/photographer_requests_content.dart';

void main() {
  group('Phase 6 - Booking Creation & State Transitions', () {
    test('BookingModel serialization and deserialization', () {
      final now = DateTime.now();
      final model = BookingModel(
        id: 'book_101',
        customerId: 'cust_abc',
        photographerId: 'photo_xyz',
        photographerName: 'Arjun Photography',
        category: 'Weddings',
        date: now,
        time: '11:00 AM',
        location: 'Bengaluru Palace',
        notes: 'Pre-wedding candid shoot',
        amount: 10000.0,
        platformFee: 500.0,
        photographerAmount: 9500.0,
        status: 'Pending',
        price: '₹10,000 onwards',
      );

      final map = model.toMap();
      expect(map['photographerName'], 'Arjun Photography');
      expect(map['amount'], 10000.0);
      expect(map['platformFee'], 500.0);
      expect(map['photographerAmount'], 9500.0);
      expect(map['status'], 'Pending');

      final fromMap = BookingModel.fromMap(map, 'book_101');
      expect(fromMap.id, 'book_101');
      expect(fromMap.photographerName, 'Arjun Photography');
      expect(fromMap.amount, 10000.0);
      expect(fromMap.platformFee, 500.0);
    });

    test('BookingStatus transitions validation', () {
      // Pending transitions
      expect(BookingStatus.pending.canTransitionTo(BookingStatus.accepted), true);
      expect(BookingStatus.pending.canTransitionTo(BookingStatus.rejected), true);
      expect(BookingStatus.pending.canTransitionTo(BookingStatus.cancelled), true);
      expect(BookingStatus.pending.canTransitionTo(BookingStatus.completed), false);

      // Accepted transitions
      expect(BookingStatus.accepted.canTransitionTo(BookingStatus.completed), true);
      expect(BookingStatus.accepted.canTransitionTo(BookingStatus.cancelled), true);
      expect(BookingStatus.accepted.canTransitionTo(BookingStatus.rejected), false);

      // Terminal states
      expect(BookingStatus.rejected.canTransitionTo(BookingStatus.accepted), false);
      expect(BookingStatus.cancelled.canTransitionTo(BookingStatus.pending), false);
      expect(BookingStatus.completed.canTransitionTo(BookingStatus.accepted), false);
    });

    testWidgets('Customer creates booking via BookingScreen',
        (WidgetTester tester) async {
      final store = PypStore();
      final photographer = PhotographerModel(
        id: 'photo_1',
        uid: 'user_1',
        name: 'Arjun Photography',
        category: 'Weddings',
        specialty: 'Wedding • Candid',
        rating: '4.9',
        price: '₹8,000 onwards',
        startingPrice: 8000.0,
        location: 'Bengaluru',
        bio: 'Wedding specialist',
        phone: '',
        email: '',
        instagram: '',
        verified: true,
        acceptingBookings: true,
        portfolio: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookingScreen(photographer: photographer, store: store),
        ),
      );
      await tester.pumpAndSettle();

      // Verify screen title
      expect(find.text('Book Photographer'), findsOneWidget);

      // Select date
      await tester.tap(find.text('Choose a date'));
      await tester.pumpAndSettle();

      // Tap OK on the date picker
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Submit booking
      final confirmBtn = find.text('Confirm booking');
      await tester.ensureVisible(confirmBtn);
      await tester.pumpAndSettle();
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Booking request sent'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Verify store updated with platform fee calculated (5% of 8000 = 400)
      expect(store.bookings.length, 1);
      expect(store.bookings.first.photographerName, 'Arjun Photography');
      expect(store.bookings.first.status, 'Pending');
      expect(store.bookings.first.amount, 8000.0);
      expect(store.bookings.first.platformFee, 400.0);
      expect(store.bookings.first.photographerAmount, 7600.0);
    });

    testWidgets('CustomerBookingsContent displays bookings and allows cancellation',
        (WidgetTester tester) async {
      final store = PypStore();
      store.addBooking(
        BookingModel(
          id: 'b1',
          photographerName: 'Frame Stories',
          category: 'Portraits',
          date: DateTime.now().add(const Duration(days: 2)),
          time: '2:00 PM',
          status: 'Pending',
          price: '₹5,000 onwards',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingsContent(store: store),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify booking listed
      expect(find.text('Frame Stories'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);

      // Cancel booking
      await tester.tap(find.text('Cancel booking'));
      await tester.pumpAndSettle();

      // Verify status updated to Cancelled
      expect(store.bookings.first.status, 'Cancelled');
      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('PhotographerRequests displays incoming requests and allows Accept/Reject',
        (WidgetTester tester) async {
      final store = PypStore();
      store.photographerAccount = PhotographerModel(
        id: 'photo_test',
        uid: 'uid_test',
        name: 'Arjun Photography',
        category: 'Weddings',
        specialty: 'Candid',
        rating: '4.9',
        price: '₹8,000 onwards',
        location: 'Bengaluru',
        bio: '',
        phone: '',
        email: '',
        instagram: '',
        verified: true,
        acceptingBookings: true,
        portfolio: [],
      );

      store.addBooking(
        BookingModel(
          id: 'req_1',
          photographerName: 'Arjun Photography',
          category: 'Weddings',
          date: DateTime.now().add(const Duration(days: 5)),
          time: '10:00 AM',
          status: 'Pending',
          price: '₹8,000 onwards',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotographerRequests(store: store),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify request listed
      expect(find.text('Customer booking request'), findsOneWidget);
      expect(find.text('Weddings'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);

      // Accept request
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      // Verify status updated to Accepted
      expect(store.bookings.first.status, 'Accepted');
    });
  });
}
