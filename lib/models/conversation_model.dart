import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final String customerId;
  final String photographerId;
  final String lastMessage;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  const ConversationModel({
    required this.id,
    required this.customerId,
    required this.photographerId,
    this.lastMessage = '',
    this.updatedAt,
    this.createdAt,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map, String docId) {
    return ConversationModel(
      id: docId,
      customerId: map['customerId'] as String? ?? '',
      photographerId: map['photographerId'] as String? ?? '',
      lastMessage: map['lastMessage'] as String? ?? '',
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversationId': id,
      'customerId': customerId,
      'photographerId': photographerId,
      'lastMessage': lastMessage,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}

class ChatMessageModel {
  final String id;
  final String senderId;
  final String message;
  final String type;
  final DateTime? createdAt;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.message,
    this.type = 'text',
    this.createdAt,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return ChatMessageModel(
      id: docId,
      senderId: map['senderId'] as String? ?? '',
      message: map['message'] as String? ?? '',
      type: map['type'] as String? ?? 'text',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': id,
      'senderId': senderId,
      'message': message,
      'type': type,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
