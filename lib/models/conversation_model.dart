import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final String? bookingId;
  final String customerId;
  final String photographerId;
  final String customerName;
  final String photographerName;
  final String? customerPhoto;
  final String? photographerPhoto;
  final List<String> participants;
  final String lastMessage;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  const ConversationModel({
    required this.id,
    this.bookingId,
    required this.customerId,
    required this.photographerId,
    this.customerName = '',
    this.photographerName = '',
    this.customerPhoto,
    this.photographerPhoto,
    this.participants = const [],
    this.lastMessage = '',
    this.updatedAt,
    this.createdAt,
  });

  bool matchesUser(List<String> userIdentifiers) {
    final cleanIdentifiers = userIdentifiers
        .map((e) => e.toLowerCase().trim())
        .where((e) => e.isNotEmpty && e != 'user@example.com' && e != 'pyp user')
        .toSet();

    if (cleanIdentifiers.isEmpty) return false;

    for (final p in participants) {
      if (cleanIdentifiers.contains(p.toLowerCase().trim())) return true;
    }
    if (customerId.isNotEmpty && cleanIdentifiers.contains(customerId.toLowerCase().trim())) {
      return true;
    }
    if (photographerId.isNotEmpty &&
        cleanIdentifiers.contains(photographerId.toLowerCase().trim())) {
      return true;
    }
    if (customerName.isNotEmpty &&
        cleanIdentifiers.contains(customerName.toLowerCase().trim())) {
      return true;
    }
    if (photographerName.isNotEmpty &&
        cleanIdentifiers.contains(photographerName.toLowerCase().trim())) {
      return true;
    }

    return false;
  }

  String getOtherParticipantName(dynamic userContext) {
    Set<String> cleanIdentifiers = {};
    if (userContext is List<String>) {
      cleanIdentifiers = userContext.map((e) => e.toLowerCase().trim()).toSet();
    } else if (userContext is String) {
      cleanIdentifiers = {userContext.toLowerCase().trim()};
    }

    final isCustomer = cleanIdentifiers.contains(customerId.toLowerCase().trim()) ||
        (customerName.isNotEmpty &&
            cleanIdentifiers.contains(customerName.toLowerCase().trim()));

    if (isCustomer) {
      return photographerName.isNotEmpty ? photographerName : 'Photographer';
    } else {
      return customerName.isNotEmpty ? customerName : 'Customer';
    }
  }

  String? getOtherParticipantPhoto(dynamic userContext) {
    Set<String> cleanIdentifiers = {};
    if (userContext is List<String>) {
      cleanIdentifiers = userContext.map((e) => e.toLowerCase().trim()).toSet();
    } else if (userContext is String) {
      cleanIdentifiers = {userContext.toLowerCase().trim()};
    }

    final isCustomer = cleanIdentifiers.contains(customerId.toLowerCase().trim()) ||
        (customerName.isNotEmpty &&
            cleanIdentifiers.contains(customerName.toLowerCase().trim()));

    if (isCustomer) {
      return photographerPhoto;
    } else {
      return customerPhoto;
    }
  }

  factory ConversationModel.fromMap(Map<String, dynamic> map, String docId) {
    final customerId = map['customerId'] as String? ?? '';
    final photographerId = map['photographerId'] as String? ?? '';
    final rawParticipants = map['participants'] as List<dynamic>?;
    final participantsList = rawParticipants?.map((e) => e.toString()).toList() ?? [];

    if (participantsList.isEmpty) {
      if (customerId.isNotEmpty) participantsList.add(customerId);
      if (photographerId.isNotEmpty && !participantsList.contains(photographerId)) {
        participantsList.add(photographerId);
      }
    }

    DateTime? parsedUpdatedAt;
    if (map['updatedAt'] is Timestamp) {
      parsedUpdatedAt = (map['updatedAt'] as Timestamp).toDate();
    } else if (map['updatedAt'] is String) {
      parsedUpdatedAt = DateTime.tryParse(map['updatedAt']);
    }

    DateTime? parsedCreatedAt;
    if (map['createdAt'] is Timestamp) {
      parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedCreatedAt = DateTime.tryParse(map['createdAt']);
    }

    return ConversationModel(
      id: docId,
      bookingId: map['bookingId'] as String?,
      customerId: customerId,
      photographerId: photographerId,
      customerName: map['customerName'] as String? ?? '',
      photographerName: map['photographerName'] as String? ?? '',
      customerPhoto: map['customerPhoto'] as String?,
      photographerPhoto: map['photographerPhoto'] as String?,
      participants: participantsList,
      lastMessage: map['lastMessage'] as String? ?? '',
      updatedAt: parsedUpdatedAt,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final parts = participants.isNotEmpty
        ? participants
        : [customerId, photographerId].where((s) => s.isNotEmpty).toList();

    return {
      'conversationId': id,
      if (bookingId != null) 'bookingId': bookingId,
      'customerId': customerId,
      'photographerId': photographerId,
      'customerName': customerName,
      'photographerName': photographerName,
      if (customerPhoto != null) 'customerPhoto': customerPhoto,
      if (photographerPhoto != null) 'photographerPhoto': photographerPhoto,
      'participants': parts,
      'lastMessage': lastMessage,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  ConversationModel copyWith({
    String? id,
    String? bookingId,
    String? customerId,
    String? photographerId,
    String? customerName,
    String? photographerName,
    String? customerPhoto,
    String? photographerPhoto,
    List<String>? participants,
    String? lastMessage,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      photographerId: photographerId ?? this.photographerId,
      customerName: customerName ?? this.customerName,
      photographerName: photographerName ?? this.photographerName,
      customerPhoto: customerPhoto ?? this.customerPhoto,
      photographerPhoto: photographerPhoto ?? this.photographerPhoto,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final String type;
  final DateTime? createdAt;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    this.senderName = '',
    required this.message,
    this.type = 'text',
    this.createdAt,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? dt;
    if (map['createdAt'] is Timestamp) {
      dt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      dt = DateTime.tryParse(map['createdAt']);
    } else {
      dt = DateTime.now();
    }

    return ChatMessageModel(
      id: docId,
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      message: map['message'] as String? ?? '',
      type: map['type'] as String? ?? 'text',
      createdAt: dt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': id,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'type': type,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
