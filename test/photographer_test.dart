import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyp_app/models/photographer_model.dart';
import 'package:pyp_app/models/user_model.dart';
import 'package:pyp_app/providers/pyp_store.dart';
import 'package:pyp_app/screens/customer/discover_content.dart';
import 'package:pyp_app/screens/photographer/photographer_onboarding_screen.dart';
import 'test_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  group('Phase 4 - Photographer Integration Tests', () {
    test('PhotographerModel serialization and deserialization', () {
      final model = PhotographerModel(
        id: 'photo-1',
        uid: 'user-1',
        name: 'Aarav Sharma',
        category: 'Weddings',
        specialty: 'Candid & Traditional',
        rating: '4.9',
        price: '₹12,000 onwards',
        startingPrice: 12000,
        location: 'Bengaluru',
        bio: 'Award-winning wedding photographer.',
        phone: '+91 9876543210',
        email: 'aarav@example.com',
        instagram: '@aarav_snaps',
        verified: true,
        acceptingBookings: true,
        portfolio: ['url1', 'url2'],
      );

      final map = model.toMap();
      expect(map['name'], 'Aarav Sharma');
      expect(map['category'], 'Weddings');
      expect(map['uid'], 'user-1');

      final fromMap = PhotographerModel.fromMap(map, 'photo-1');
      expect(fromMap.id, 'photo-1');
      expect(fromMap.name, 'Aarav Sharma');
      expect(fromMap.category, 'Weddings');
      expect(fromMap.verified, true);
    });

    testWidgets('DiscoverContent renders photographer cards and filters by category',
        (WidgetTester tester) async {
      final store = PypStore();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscoverContent(store: store),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Discover title
      expect(find.text('Discover'), findsOneWidget);

      // Verify category chips exist
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Weddings'), findsOneWidget);
      expect(find.text('Portraits'), findsOneWidget);

      // Verify default photographers are rendered
      expect(find.text('Arjun Photography'), findsOneWidget);
    });

    testWidgets('Photographer Onboarding creates profile in store',
        (WidgetTester tester) async {
      final store = PypStore();

      await tester.pumpWidget(
        MaterialApp(
          home: PhotographerOnboardingScreen(store: store),
        ),
      );
      await tester.pumpAndSettle();

      // Verify onboarding title
      expect(find.text('Build your photographer profile'), findsOneWidget);

      // Fill in form fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Business / photographer name'),
        'Studio Eclipse',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Specialty'),
        'Cinematic Weddings',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Starting price'),
        '₹15,000 onwards',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'About you'),
        'Passionate visual storyteller with 6 years experience.',
      );

      // Scroll into view and submit
      final buttonFinder = find.text('Create photographer account');
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Verify store state updated
      expect(store.photographerAccount, isNotNull);
      expect(store.photographerAccount!.name, 'Studio Eclipse');
      expect(store.photographerAccount!.location, isNotEmpty);
      expect(store.role, UserRole.photographer);
    });
  });
}

