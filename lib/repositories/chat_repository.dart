import '../models/conversation_model.dart';
import '../services/chat_service.dart';

class ChatRepository {
  final ChatService _service;

  ChatRepository({ChatService? service}) : _service = service ?? ChatService();

  Stream<List<ConversationModel>> getConversations(dynamic userIdentifiers) {
    if (userIdentifiers is List<String>) {
      return _service.streamConversations(userIdentifiers);
    } else if (userIdentifiers is String) {
      return _service.streamConversations([userIdentifiers]);
    }
    return Stream.value([]);
  }

  Stream<List<ChatMessageModel>> streamMessages(String conversationId) {
    return _service.streamMessages(conversationId);
  }

  Stream<List<ChatMessageModel>> getMessages(String conversationId) {
    return _service.streamMessages(conversationId);
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
  }) {
    return _service.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      message: message,
      senderName: senderName,
      recipientId: recipientId,
      recipientName: recipientName,
      customerName: customerName,
      photographerName: photographerName,
      customerId: customerId,
      photographerId: photographerId,
      additionalParticipants: additionalParticipants,
      type: type,
    );
  }

  Future<String> getOrCreateConversation({
    required String customerId,
    required String photographerId,
    String customerName = '',
    String photographerName = '',
    String? customerPhoto,
    String? photographerPhoto,
    List<String>? allParticipants,
  }) {
    return _service.getOrCreateConversation(
      customerId: customerId,
      photographerId: photographerId,
      customerName: customerName,
      photographerName: photographerName,
      customerPhoto: customerPhoto,
      photographerPhoto: photographerPhoto,
      allParticipants: allParticipants,
    );
  }
}
