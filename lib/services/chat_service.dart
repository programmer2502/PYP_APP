import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exceptions.dart';
import '../models/conversation_model.dart';
import 'firestore_service.dart';

class ChatService {
  final FirestoreService _firestoreService;

  ChatService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<ConversationModel>> streamConversations(List<String> userIdentifiers) {
    if (!_firestoreService.isReady || userIdentifiers.isEmpty) {
      return Stream.value([]);
    }

    final cleanIdentifiers = userIdentifiers
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s != 'user@example.com' && s != 'PYP User')
        .toSet()
        .toList();

    if (cleanIdentifiers.isEmpty) {
      return Stream.value([]);
    }

    return _firestoreService
        .collection(FirestoreCollections.conversations)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
              .where((convo) => convo.matchesUser(cleanIdentifiers))
              .toList();

          list.sort((a, b) {
            final aTime = a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });
          return list;
        });
  }

  Stream<List<ChatMessageModel>> streamMessages(String conversationId) {
    if (!_firestoreService.isReady || conversationId.isEmpty) {
      return Stream.value([]);
    }

    return _firestoreService
        .collection(FirestoreCollections.conversations)
        .doc(conversationId)
        .collection(FirestoreCollections.messages)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
              .toList();

          list.sort((a, b) {
            final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });

          return list;
        });
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String message,
    String senderName = '',
    String? recipientId,
    String? recipientName,
    String? customerName,
    String? photographerName,
    String? customerId,
    String? photographerId,
    List<String>? additionalParticipants,
    String type = 'text',
  }) async {
    if (!_firestoreService.isReady) return;

    try {
      final msg = ChatMessageModel(
        id: '',
        senderId: senderId,
        senderName: senderName,
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

      final allParts = <String>{
        senderId,
        if (senderName.isNotEmpty) senderName,
        if (recipientId != null && recipientId.isNotEmpty) recipientId,
        if (recipientName != null && recipientName.isNotEmpty) recipientName,
        if (customerId != null && customerId.isNotEmpty) customerId,
        if (photographerId != null && photographerId.isNotEmpty) photographerId,
        if (customerName != null && customerName.isNotEmpty) customerName,
        if (photographerName != null && photographerName.isNotEmpty) photographerName,
        ...?additionalParticipants,
      }.where((s) => s.trim().isNotEmpty && s != 'user@example.com' && s != 'PYP User').toList();

      final updateMap = <String, dynamic>{
        'conversationId': conversationId,
        'lastMessage': message,
        'updatedAt': FieldValue.serverTimestamp(),
        'participants': FieldValue.arrayUnion(allParts),
      };

      if (customerId != null && customerId.isNotEmpty) {
        updateMap['customerId'] = customerId;
      }
      if (photographerId != null && photographerId.isNotEmpty) {
        updateMap['photographerId'] = photographerId;
      }
      if (customerName != null && customerName.isNotEmpty) {
        updateMap['customerName'] = customerName;
      }
      if (photographerName != null && photographerName.isNotEmpty) {
        updateMap['photographerName'] = photographerName;
      }

      batch.set(
        convoRef,
        updateMap,
        SetOptions(merge: true),
      );

      await batch.commit();
    } catch (e) {
      throw FirestoreException('Failed to send message: $e');
    }
  }

  Future<ConversationModel?> getConversationForBooking(String bookingId) async {
    if (!_firestoreService.isReady || bookingId.isEmpty) return null;

    try {
      final query = await _firestoreService
          .collection(FirestoreCollections.conversations)
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return ConversationModel.fromMap(query.docs.first.data(), query.docs.first.id);
      }

      final safeId = 'convo_bk_${bookingId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')}';
      final doc = await _firestoreService
          .collection(FirestoreCollections.conversations)
          .doc(safeId)
          .get();

      if (doc.exists && doc.data() != null) {
        return ConversationModel.fromMap(doc.data()!, doc.id);
      }
    } catch (_) {}

    return null;
  }

  Future<String> getOrCreateConversation({
    required String customerId,
    required String photographerId,
    String? bookingId,
    String customerName = '',
    String photographerName = '',
    String? customerPhoto,
    String? photographerPhoto,
    List<String>? allParticipants,
  }) async {
    final String deterministicId;
    if (bookingId != null && bookingId.isNotEmpty) {
      final safeBooking = bookingId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      deterministicId = 'convo_bk_$safeBooking';
    } else {
      final safeCust = customerId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      final safePhoto = photographerId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      deterministicId = 'convo_${safeCust}_$safePhoto';
    }

    if (!_firestoreService.isReady) {
      return deterministicId;
    }

    try {
      final convoRef = _firestoreService
          .collection(FirestoreCollections.conversations)
          .doc(deterministicId);

      final doc = await convoRef.get();
      final participantsList = <String>{
        customerId,
        photographerId,
        if (customerName.isNotEmpty) customerName,
        if (photographerName.isNotEmpty) photographerName,
        ...?allParticipants,
      }.where((s) => s.trim().isNotEmpty && s != 'user@example.com' && s != 'PYP User').toList();

      if (doc.exists) {
        await convoRef.set({
          'participants': FieldValue.arrayUnion(participantsList),
          if (bookingId != null && bookingId.isNotEmpty) 'bookingId': bookingId,
          if (customerName.isNotEmpty) 'customerName': customerName,
          if (photographerName.isNotEmpty) 'photographerName': photographerName,
          'customerPhoto': ?customerPhoto,
          'photographerPhoto': ?photographerPhoto,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return doc.id;
      }

      final newConvo = ConversationModel(
        id: deterministicId,
        bookingId: bookingId,
        customerId: customerId,
        photographerId: photographerId,
        customerName: customerName,
        photographerName: photographerName,
        customerPhoto: customerPhoto,
        photographerPhoto: photographerPhoto,
        participants: participantsList,
        lastMessage: 'Conversation started',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await convoRef.set(newConvo.toMap(), SetOptions(merge: true));
      return deterministicId;
    } catch (e) {
      return deterministicId;
    }
  }
}
