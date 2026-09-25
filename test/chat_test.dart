import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyp_app/models/conversation_model.dart';
import 'package:pyp_app/screens/chat/chat_inbox_screen.dart';
import 'package:pyp_app/screens/chat/chat_room_screen.dart';
import 'package:pyp_app/services/fcm_service.dart';

void main() {
  group('Phase 10 - Chat & Messaging Unit Tests', () {
    test('ConversationModel serialization and deserialization', () {
      final now = DateTime(2026, 9, 18, 12, 0);
      final model = ConversationModel(
        id: 'convo_123',
        customerId: 'cust_abc',
        photographerId: 'photo_xyz',
        lastMessage: 'Hello there!',
        createdAt: now,
        updatedAt: now,
      );

      expect(model.id, 'convo_123');
      expect(model.customerId, 'cust_abc');
      expect(model.photographerId, 'photo_xyz');
      expect(model.lastMessage, 'Hello there!');

      final map = model.toMap();
      expect(map['conversationId'], 'convo_123');
      expect(map['customerId'], 'cust_abc');
      expect(map['photographerId'], 'photo_xyz');
      expect(map['lastMessage'], 'Hello there!');
    });

    test('ChatMessageModel serialization and deserialization', () {
      final now = DateTime(2026, 9, 18, 12, 0);
      final msg = ChatMessageModel(
        id: 'msg_456',
        senderId: 'cust_abc',
        message: 'Looking forward to the shoot!',
        type: 'text',
        createdAt: now,
      );

      expect(msg.id, 'msg_456');
      expect(msg.senderId, 'cust_abc');
      expect(msg.message, 'Looking forward to the shoot!');
      expect(msg.type, 'text');

      final map = msg.toMap();
      expect(map['messageId'], 'msg_456');
      expect(map['senderId'], 'cust_abc');
      expect(map['message'], 'Looking forward to the shoot!');
      expect(map['type'], 'text');
    });

    test('NotificationPayload map serialization with enum types', () {
      const payload = NotificationPayload(
        title: 'New Booking Request',
        body: 'You have received a new booking from Alex.',
        type: NotificationType.bookingRequest,
        referenceId: 'book_789',
        data: {'amount': '₹5,000'},
      );

      final map = payload.toMap();
      expect(map['title'], 'New Booking Request');
      expect(map['body'], 'You have received a new booking from Alex.');
      expect(map['type'], 'bookingRequest');
      expect(map['referenceId'], 'book_789');
      expect(map['data']['amount'], '₹5,000');
    });

    test('FCMService safe execution without active Firebase connection', () async {
      final fcmService = FCMService();

      // Gracefully handles without throwing errors
      await fcmService.saveUserFcmToken('user_test', 'token_sample');
      await fcmService.queueNotification(
        recipientUserId: 'user_target',
        payload: const NotificationPayload(
          title: 'Test',
          body: 'Test Notification',
          type: NotificationType.chatMessage,
          referenceId: 'ref_1',
        ),
      );
    });
  });

  group('Phase 10 - Chat Widget Tests', () {
    testWidgets('ChatRoomScreen renders empty state and allows typing/sending message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChatRoomScreen(
            conversationId: 'test_convo_1',
            recipientName: 'Arjun Verma',
            currentUserId: 'cust_1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify recipient name in app bar
      expect(find.text('Arjun Verma'), findsOneWidget);

      // Verify initial empty state placeholder
      expect(find.text('Chat with Arjun Verma'), findsOneWidget);

      // Enter a new chat message
      final inputFinder = find.byType(TextField);
      expect(inputFinder, findsOneWidget);
      await tester.enterText(inputFinder, 'Hi Arjun, are you free Saturday?');
      await tester.pump();

      // Tap send button
      final sendFinder = find.byIcon(Icons.send_rounded);
      expect(sendFinder, findsOneWidget);
      await tester.tap(sendFinder);
      await tester.pumpAndSettle();

      // Verify message is added to local bubbles immediately
      expect(find.text('Hi Arjun, are you free Saturday?'), findsOneWidget);
      expect(find.text('Chat with Arjun Verma'), findsNothing);
    });

    testWidgets('ChatInboxScreen displays empty state when no conversations',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChatInboxScreen(
            currentUserId: 'cust_1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify screen title and empty state
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('No conversations yet'), findsOneWidget);
    });
  });
}
