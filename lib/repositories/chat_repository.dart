import '../models/conversation_model.dart';
import '../services/chat_service.dart';

class ChatRepository {
  final ChatService _service;

  ChatRepository({ChatService? service}) : _service = service ?? ChatService();

  Stream<List<ConversationModel>> getConversations(String userId) {
    return _service.streamConversations(userId);
  }

  Stream<List<ChatMessageModel>> getMessages(String conversationId) {
    return _service.streamMessages(conversationId);
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String message,
  }) {
    return _service.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      message: message,
    );
  }

  Future<String> getOrCreateConversation({
    required String customerId,
    required String photographerId,
  }) {
    return _service.getOrCreateConversation(
      customerId: customerId,
      photographerId: photographerId,
    );
  }
}
