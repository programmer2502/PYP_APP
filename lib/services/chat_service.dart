import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exceptions.dart';
import '../models/conversation_model.dart';
import 'firestore_service.dart';

class ChatService {
  final FirestoreService _firestoreService;

  ChatService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<ConversationModel>> streamConversations(String userId) {
    if (!_firestoreService.isReady) {
      return Stream.value([]);
    }

    return _firestoreService
        .collection(FirestoreCollections.conversations)
        .where(Filter.or(
          Filter('customerId', isEqualTo: userId),
          Filter('photographerId', isEqualTo: userId),
        ))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ChatMessageModel>> streamMessages(String conversationId) {
    if (!_firestoreService.isReady) {
      return Stream.value([]);
    }

    return _firestoreService
        .collection(FirestoreCollections.conversations)
        .doc(conversationId)
        .collection(FirestoreCollections.messages)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String message,
    String type = 'text',
  }) async {
    if (!_firestoreService.isReady) return;

    try {
      final msg = ChatMessageModel(
        id: '',
        senderId: senderId,
        message: message,
        type: type,
        createdAt: DateTime.now(),
      );

      final convoRef = _firestoreService
          .collection(FirestoreCollections.conversations)
          .doc(conversationId);

      final batch = _firestoreService.batch();
      final msgRef = convoRef.collection(FirestoreCollections.messages).doc();
      batch.set(msgRef, msg.toMap());
      batch.update(convoRef, {
        'lastMessage': message,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw FirestoreException('Failed to send message: $e');
    }
  }

  Future<String> getOrCreateConversation({
    required String customerId,
    required String photographerId,
  }) async {
    if (!_firestoreService.isReady) {
      return '${customerId}_$photographerId';
    }

    try {
      final existing = await _firestoreService
          .collection(FirestoreCollections.conversations)
          .where('customerId', isEqualTo: customerId)
          .where('photographerId', isEqualTo: photographerId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }

      final newConvo = ConversationModel(
        id: '',
        customerId: customerId,
        photographerId: photographerId,
        lastMessage: 'Conversation started',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestoreService
          .collection(FirestoreCollections.conversations)
          .add(newConvo.toMap());

      return docRef.id;
    } catch (e) {
      throw FirestoreException('Failed to get or create conversation: $e');
    }
  }
}
