import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyp_app/models/availability_model.dart';
import 'package:pyp_app/models/booking_model.dart';
import 'package:pyp_app/models/photographer_model.dart';
import 'package:pyp_app/providers/pyp_store.dart';
import 'package:pyp_app/screens/customer/booking_screen.dart';
import 'package:pyp_app/screens/photographer/photographer_calendar_content.dart';
import 'test_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  group('Phase 7 - Availability & Double-Booking Protection', () {
    test('AvailabilityModel serialization and deserialization', () {
      final now = DateTime(2026, 10, 24);
      final model = AvailabilityModel(
        id: 'avail_1',
        photographerId: 'photo_abc',
        date: now,
        startTime: '10:00 AM',
        endTime: '06:00 PM',
        status: AvailabilityStatus.blocked,
      );

      final map = model.toMap();
      expect(map['photographerId'], 'photo_abc');
      expect(map['startTime'], '10:00 AM');
      expect(map['status'], 'blocked');

      final fromMap = AvailabilityModel.fromMap(map, 'avail_1');
      expect(fromMap.id, 'avail_1');
      expect(fromMap.photographerId, 'photo_abc');
      expect(fromMap.status, AvailabilityStatus.blocked);
    });

    testWidgets('PhotographerCalendar displays schedule, allows filtering and toggles availability switch',
        (WidgetTester tester) async {
      final store = PypStore();
      store.photographerAccount = PhotographerModel(
        id: 'photo_1',
        uid: 'user_1',
        name: 'Arjun Photography',
        category: 'Weddings',
        specialty: 'Wedding • Candid',
        rating: '4.9',
        price: '₹8,000 onwards',
        location: 'Bengaluru',
        bio: 'Bio',
        phone: '',
        email: '',
        instagram: '',
        verified: true,
        acceptingBookings: true,
        portfolio: [],
      );

      store.addBooking(
        BookingModel(
          id: 'b1',
          photographerName: 'Arjun Photography',
          category: 'Weddings',
          date: DateTime.now().add(const Duration(days: 3)),
          time: '10:00 AM',
          status: 'Accepted',
          price: '₹8,000 onwards',
        ),
      );

      store.addBooking(
        BookingModel(
          id: 'b2',
          photographerName: 'Arjun Photography',
          category: 'Weddings',
          date: DateTime.now().add(const Duration(days: 5)),
          time: '2:00 PM',
          status: 'Pending',
          price: '₹8,000 onwards',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotographerCalendar(store: store),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title and availability banner
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Accepting New Bookings'), findsOneWidget);

      // Verify filter chips with counts (All: 2, Accepted: 1, Pending: 1)
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Pending'), findsNWidgets(2)); // Chip and Card status badge
      expect(find.text('Accepted'), findsNWidgets(2)); // Chip and Card status badge


      // Filter by Accepted
      await tester.tap(find.text('Accepted').first);
      await tester.pumpAndSettle();
      expect(find.text('10:00 AM'), findsOneWidget);

      // Toggle switch to pause schedule
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Verify store state updated
      expect(store.photographerAccount!.acceptingBookings, false);
      expect(find.text('Schedule Paused'), findsOneWidget);
    });

    testWidgets('BookingScreen disables booking when photographer is unavailable',
        (WidgetTester tester) async {
      final store = PypStore();
      final unavailablePhotographer = PhotographerModel(
        id: 'photo_busy',
        uid: 'user_busy',
        name: 'Studio Eclipse',
        category: 'Weddings',
        specialty: 'Cinematic',
        rating: '4.8',
        price: '₹12,000 onwards',
        location: 'Mumbai',
        bio: 'Bio',
        phone: '',
        email: '',
        instagram: '',
        verified: true,
        acceptingBookings: false, // Paused schedule
        portfolio: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookingScreen(
            photographer: unavailablePhotographer,
            store: store,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify advisory banner and disabled button
      expect(
        find.text('This photographer has paused their booking schedule.'),
        findsOneWidget,
      );

      final unavailableBtn = find.text('Currently Unavailable');
      await tester.ensureVisible(unavailableBtn);
      await tester.pumpAndSettle();

      expect(unavailableBtn, findsOneWidget);

      // Tapping unavailable button should not trigger booking
      await tester.tap(unavailableBtn);
      await tester.pumpAndSettle();
      expect(store.bookings, isEmpty);
    });
  });
}

