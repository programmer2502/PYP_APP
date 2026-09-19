import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/conversation_model.dart';
import '../models/photographer_model.dart';
import '../repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository;

  String? _errorMessage;
  List<String> _currentUserIdentifiers = [];
  List<ConversationModel> _conversations = [];
  List<ChatMessageModel> _messages = [];
  final Map<String, List<ChatMessageModel>> _localMessageStore = {};
  StreamSubscription<List<ConversationModel>>? _convoSubscription;
  StreamSubscription<List<ChatMessageModel>>? _msgSubscription;

  ChatProvider({ChatRepository? repository})
      : _repository = repository ?? ChatRepository();

  String? get errorMessage => _errorMessage;
  List<ConversationModel> get conversations => _conversations;
  List<ChatMessageModel> get messages => _messages;
  List<String> get currentUserIdentifiers => _currentUserIdentifiers;

  void streamConversations(dynamic userIdentifiers) {
    List<String> identifiersList = [];
    if (userIdentifiers is List<String>) {
      identifiersList = userIdentifiers.where((s) => s.trim().isNotEmpty).toList();
    } else if (userIdentifiers is String && userIdentifiers.trim().isNotEmpty) {
      identifiersList = [userIdentifiers.trim()];
    }

    _currentUserIdentifiers = identifiersList;
    _convoSubscription?.cancel();

    _convoSubscription = _repository.getConversations(identifiersList).listen(
      (items) {
        final existingIds = items.map((c) => c.id).toSet();
        final nonDuplicateLocal =
            _conversations.where((c) => !existingIds.contains(c.id)).toList();
        _conversations = [...items, ...nonDuplicateLocal];
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

    if (_localMessageStore.containsKey(conversationId)) {
      _messages = List.from(_localMessageStore[conversationId]!);
      notifyListeners();
    } else {
      _messages = [];
    }

    _msgSubscription = _repository.getMessages(conversationId).listen(
      (items) {
        if (items.isNotEmpty) {
          _messages = items;
          _localMessageStore[conversationId] = List.from(items);
        }
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
    final newMsg = ChatMessageModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      message: message,
      type: type,
      createdAt: DateTime.now(),
    );

    // Optimistic local update
    _messages.insert(0, newMsg);
    _localMessageStore[conversationId] = List.from(_messages);

    final allParticipants = <String>{
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

    // Update conversation last message in local list
    final convoIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (convoIndex != -1) {
      final updated = _conversations[convoIndex].copyWith(
        lastMessage: message,
        updatedAt: DateTime.now(),
        participants: allParticipants,
      );
      _conversations.removeAt(convoIndex);
      _conversations.insert(0, updated);
    } else {
      _conversations.insert(
        0,
        ConversationModel(
          id: conversationId,
          customerId: customerId ?? senderId,
          photographerId: photographerId ?? recipientId ?? '',
          customerName: customerName ?? senderName,
          photographerName: photographerName ?? recipientName ?? 'Photographer',
          participants: allParticipants,
          lastMessage: message,
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();

    try {
      await _repository.sendMessage(
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
    } catch (_) {
      // Retained in-memory if offline
    }
  }

  Future<String> startConversationWithPhotographer({
    required String customerId,
    required String customerName,
    required PhotographerModel photographer,
    List<String>? customerAliases,
  }) async {
    final photoId = photographer.id.isNotEmpty
        ? photographer.id
        : (photographer.uid.isNotEmpty ? photographer.uid : photographer.name);

    final allParticipants = <String>{
      customerId,
      customerName,
      ...?customerAliases,
      photoId,
      if (photographer.uid.isNotEmpty) photographer.uid,
      if (photographer.name.isNotEmpty) photographer.name,
      if (photographer.email.isNotEmpty) photographer.email,
    }.where((s) => s.trim().isNotEmpty && s != 'user@example.com' && s != 'PYP User').toList();

    // Check if conversation already exists in active list
    final existingIndex = _conversations.indexWhere(
      (c) =>
          c.photographerId == photoId ||
          c.photographerId == photographer.uid ||
          c.photographerName.toLowerCase() == photographer.name.toLowerCase(),
    );

    if (existingIndex != -1) {
      return _conversations[existingIndex].id;
    }

    final safeCust = customerId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final safePhoto = photoId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final convoId = 'convo_${safeCust}_$safePhoto';

    final newConvo = ConversationModel(
      id: convoId,
      customerId: customerId,
      photographerId: photoId,
      customerName: customerName.isNotEmpty ? customerName : 'Customer',
      photographerName: photographer.name,
      customerPhoto: null,
      photographerPhoto: photographer.profileImageUrl,
      participants: allParticipants,
      lastMessage: 'Tap to send a message...',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _conversations.insert(0, newConvo);
    _localMessageStore[convoId] = [];
    notifyListeners();

    try {
      final serverId = await _repository.getOrCreateConversation(
        customerId: customerId,
        photographerId: photoId,
        customerName: customerName,
        photographerName: photographer.name,
        photographerPhoto: photographer.profileImageUrl,
        allParticipants: allParticipants,
      );
      return serverId;
    } catch (_) {
      return convoId;
    }
  }

  @override
  void dispose() {
    _convoSubscription?.cancel();
    _msgSubscription?.cancel();
    super.dispose();
  }
}
