import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyp_app/models/booking_model.dart';
import 'package:pyp_app/models/photographer_model.dart';
import 'package:pyp_app/providers/pyp_store.dart';
import 'package:pyp_app/screens/chat/chat_room_screen.dart';
import 'package:pyp_app/screens/customer/booking_screen.dart';
import 'package:pyp_app/screens/customer/customer_bookings_content.dart';
import 'package:pyp_app/screens/customer/discover_content.dart';
import 'package:pyp_app/screens/customer/photographer_details_screen.dart';
import 'package:pyp_app/screens/customer/saved_photographers_screen.dart';
import 'package:pyp_app/screens/photographer/photographer_calendar_content.dart';
import 'package:pyp_app/screens/photographer/photographer_requests_content.dart';
import 'package:pyp_app/screens/photographer/portfolio_manager_screen.dart';
import 'package:pyp_app/services/payment_service.dart';
import 'test_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  group('Phase 11 - End-to-End Architectural Lifecycle Tests', () {
    test('Payment Platform Fee calculations across pricing tiers', () {
      final tier1 = PaymentCalculation.fromTotal(1000);
      expect(tier1.platformFee, 50.0);
      expect(tier1.photographerAmount, 950.0);

      final tier2 = PaymentCalculation.fromTotal(5000);
      expect(tier2.platformFee, 250.0);
      expect(tier2.photographerAmount, 4750.0);

      final tier3 = PaymentCalculation.fromTotal(15000);
      expect(tier3.platformFee, 750.0);
      expect(tier3.photographerAmount, 14250.0);
    });

    testWidgets('Customer Discover and Details flows', (WidgetTester tester) async {
      final store = PypStore();
      final photographer = store.photographers.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscoverContent(store: store),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(photographer.name), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: PhotographerDetailsScreen(
            photographer: photographer,
            store: store,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(photographer.name), findsOneWidget);
      expect(find.text('Book this photographer'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();
      expect(store.isPhotographerSaved(photographer), isTrue);
    });

    testWidgets('Customer Saved Photographers flow', (WidgetTester tester) async {
      final store = PypStore();
      store.savePhotographer('Arjun Photography');

      await tester.pumpWidget(
        MaterialApp(
          home: SavedPhotographersScreen(store: store),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Saved photographers'), findsOneWidget);
      expect(find.text('Arjun Photography'), findsOneWidget);
    });

    testWidgets('Customer Booking creation flow', (WidgetTester tester) async {
      final store = PypStore();
      final photographer = store.photographers.first;

      await tester.pumpWidget(
        MaterialApp(
          home: BookingScreen(
            photographer: photographer,
            store: store,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final confirmBtn = find.byIcon(Icons.send_rounded);
      await tester.ensureVisible(confirmBtn);
      await tester.pumpAndSettle();
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(find.text('Booking Request Sent'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(store.bookings.isNotEmpty, isTrue);
    });

    testWidgets('Customer Bookings content and payment status flow',
        (WidgetTester tester) async {
      final store = PypStore();
      store.addBooking(
        BookingModel(
          id: 'b_cust_1',
          photographerName: 'Arjun Photography',
          category: 'Weddings',
          date: DateTime.now().add(const Duration(days: 3)),
          time: '11:00 AM',
          status: 'Pending',
          paymentStatus: PaymentStatus.unpaid,
          price: '₹8,000 onwards',
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
      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('Arjun Photography'), findsOneWidget);
      expect(find.text('PAYMENT LOCKED'), findsOneWidget);
    });

    testWidgets('In-App Chat room messaging flow', (WidgetTester tester) async {
      final store = PypStore();

      await tester.pumpWidget(
        MaterialApp(
          home: ChatRoomScreen(
            conversationId: 'e2e_convo_1',
            recipientName: 'Arjun Photography',
            currentUserId: store.user.email,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Arjun Photography'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Hello from E2E test!');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Hello from E2E test!'), findsOneWidget);
    });

    testWidgets('Photographer Calendar and availability toggling',
        (WidgetTester tester) async {
      final store = PypStore();
      store.photographerAccount = store.photographers.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotographerCalendar(store: store),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Accepting New Bookings'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('Schedule Paused'), findsOneWidget);
    });

    testWidgets('Photographer Portfolio Manager UI flow', (WidgetTester tester) async {
      final store = PypStore();
      store.switchToPhotographer();

      await tester.pumpWidget(
        MaterialApp(
          home: PortfolioManager(store: store),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Portfolio'), findsOneWidget);
      expect(find.text('Add portfolio work'), findsOneWidget);
      expect(find.byIcon(Icons.add_a_photo_outlined), findsOneWidget);
    });

    testWidgets('Photographer Booking Requests handling flow', (WidgetTester tester) async {
      final store = PypStore();
      store.photographerAccount = PhotographerModel(
        id: 'photo_e2e',
        uid: 'user_e2e',
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

      final sampleBooking = BookingModel(
        id: 'e2e_req_1',
        customerId: 'customer_e2e',
        photographerId: 'photo_e2e',
        photographerName: 'Arjun Photography',
        category: 'Weddings',
        date: DateTime.now().add(const Duration(days: 3)),
        time: '10:00 AM',
        location: 'Studio A',
        amount: 8000.0,
        platformFee: 400.0,
        photographerAmount: 7600.0,
        status: 'Pending',
        paymentStatus: PaymentStatus.unpaid,
        price: '₹8,000',
      );
      store.addBooking(sampleBooking);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotographerRequests(store: store),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Requests'), findsOneWidget);
      expect(find.text('Weddings'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);

      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      final updatedBooking = store.bookings.firstWhere((b) => b.id == 'e2e_req_1');
      expect(updatedBooking.status, 'Accepted');
    });
  });
}
