import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyp_app/models/photographer_model.dart';
import 'package:pyp_app/providers/pyp_store.dart';
import 'package:pyp_app/screens/customer/saved_photographers_screen.dart';
import 'package:pyp_app/widgets/customer/photographer_list_card.dart';

void main() {
  group('Phase 8 - Favorites Synchronization Tests', () {
    testWidgets('SavedPhotographersScreen displays empty state when nothing saved',
        (WidgetTester tester) async {
      final store = PypStore();
      store.savedPhotographers.clear();

      await tester.pumpWidget(
        MaterialApp(
          home: SavedPhotographersScreen(store: store),
        ),
      );
      await tester.pumpAndSettle();

      // Verify screen title and empty state
      expect(find.text('Saved photographers'), findsOneWidget);
      expect(find.text('Nothing saved yet'), findsOneWidget);
      expect(find.text('Save photographers you want to come back to.'), findsOneWidget);
    });

    testWidgets('SavedPhotographersScreen displays saved photographers dynamically',
        (WidgetTester tester) async {
      final store = PypStore();
      store.savedPhotographers.clear();

      await tester.pumpWidget(
        MaterialApp(
          home: SavedPhotographersScreen(store: store),
        ),
      );
      await tester.pumpAndSettle();

      // Initially empty
      expect(find.text('Nothing saved yet'), findsOneWidget);

      // Save a photographer (e.g., 'Arjun Photography')
      store.savePhotographer('Arjun Photography');
      await tester.pumpAndSettle();

      // Verify photographer card appears
      expect(find.text('Nothing saved yet'), findsNothing);
      expect(find.text('Arjun Photography'), findsOneWidget);

      // Unsave photographer
      store.savePhotographer('Arjun Photography');
      await tester.pumpAndSettle();

      // Verify back to empty state
      expect(find.text('Nothing saved yet'), findsOneWidget);
    });

    testWidgets('PhotographerListCard favorite button toggles store state',
        (WidgetTester tester) async {
      final store = PypStore();
      final photographer = PhotographerModel(
        id: 'photo_fav_1',
        uid: 'user_fav_1',
        name: 'Frame Stories',
        category: 'Portraits',
        specialty: 'Portrait • Fashion',
        rating: '4.8',
        price: '₹5,000 onwards',
        location: 'Bengaluru',
        bio: 'Bio',
        phone: '',
        email: '',
        instagram: '',
        verified: true,
        acceptingBookings: true,
        portfolio: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotographerListCard(
              photographer: photographer,
              store: store,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially not saved
      expect(store.isSaved('Frame Stories'), false);
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

      // Tap favorite icon
      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();

      // Verify saved in store
      expect(store.isSaved('Frame Stories'), true);
    });
  });
}
