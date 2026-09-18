import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyp_app/models/photographer_model.dart';
import 'package:pyp_app/models/portfolio_model.dart';
import 'package:pyp_app/providers/pyp_store.dart';
import 'package:pyp_app/screens/photographer/portfolio_manager_screen.dart';

void main() {
  group('Phase 5 - Storage & Portfolio Integration Tests', () {
    test('PortfolioModel serialization and deserialization', () {
      final model = PortfolioModel(
        id: 'port_123',
        photographerId: 'photo_456',
        title: 'Sunset Wedding in Goa',
        description: 'Golden hour portraits on the beach.',
        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/pyp-app.appspot.com/o/portfolio%2Fphoto_456%2Fport_123.jpg',
        storagePath: 'portfolio/photo_456/port_123.jpg',
        createdAt: DateTime.now(),
      );

      final map = model.toMap();
      expect(map['title'], 'Sunset Wedding in Goa');
      expect(map['photographerId'], 'photo_456');
      expect(map['storagePath'], 'portfolio/photo_456/port_123.jpg');

      final fromMap = PortfolioModel.fromMap(map, 'port_123');
      expect(fromMap.id, 'port_123');
      expect(fromMap.title, 'Sunset Wedding in Goa');
      expect(fromMap.imageUrl, contains('firebase'));
    });

    testWidgets('PortfolioManager renders and handles portfolio operations',
        (WidgetTester tester) async {
      final store = PypStore();
      store.photographerAccount = PhotographerModel(
        id: 'test_photo',
        uid: 'test_uid',
        name: 'Test Photographer',
        category: 'Weddings',
        specialty: 'Candid',
        rating: '5.0',
        price: '₹10,000',
        location: 'Bengaluru',
        bio: 'Bio',
        phone: '',
        email: '',
        instagram: '',
        verified: true,
        acceptingBookings: true,
        portfolio: ['Sample Pre-Wedding Shoot'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PortfolioManager(store: store),
        ),
      );
      await tester.pumpAndSettle();

      // Verify screen title and existing item
      expect(find.text('Portfolio'), findsOneWidget);
      expect(find.text('Sample Pre-Wedding Shoot'), findsOneWidget);

      // Add a new text portfolio item
      await tester.enterText(
        find.widgetWithText(TextField, 'Work title or caption'),
        'Beach Ceremony Highlights',
      );
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      // Verify both items present
      expect(find.text('Beach Ceremony Highlights'), findsOneWidget);
      expect(store.photographerAccount!.portfolio.length, 2);

      // Delete the first item
      await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
      await tester.pumpAndSettle();

      // Verify item removed
      expect(store.photographerAccount!.portfolio.length, 1);
      expect(store.photographerAccount!.portfolio.first, 'Beach Ceremony Highlights');
    });
  });
}
