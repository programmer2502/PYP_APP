import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/conversation_model.dart';
import '../repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<ConversationModel> _conversations = [];
  List<ChatMessageModel> _messages = [];
  StreamSubscription<List<ConversationModel>>? _convoSubscription;
  StreamSubscription<List<ChatMessageModel>>? _msgSubscription;

  ChatProvider({ChatRepository? repository})
      : _repository = repository ?? ChatRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ConversationModel> get conversations => _conversations;
  List<ChatMessageModel> get messages => _messages;

  void streamConversations(String userId) {
    _convoSubscription?.cancel();
    _convoSubscription = _repository.getConversations(userId).listen(
      (items) {
        _conversations = items;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  void streamMessages(String conversationId) {
    _msgSubscription?.cancel();
    _msgSubscription = _repository.getMessages(conversationId).listen(
      (items) {
        _messages = items;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String message,
  }) async {
    try {
      await _repository.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        message: message,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<String> getOrCreateConversation({
    required String customerId,
    required String photographerId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await _repository.getOrCreateConversation(
        customerId: customerId,
        photographerId: photographerId,
      );
      _isLoading = false;
      notifyListeners();
      return id;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _convoSubscription?.cancel();
    _msgSubscription?.cancel();
    super.dispose();
  }
}
