import 'package:cloud_firestore/cloud_firestore.dart';

enum AppNotificationType {
  bookingRequest,
  bookingAccepted,
  bookingRejected,
  bookingCancelled,
  chatMessage,
  system;

  static AppNotificationType fromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'bookingrequest':
      case 'booking_request':
        return AppNotificationType.bookingRequest;
      case 'bookingaccepted':
      case 'booking_accepted':
        return AppNotificationType.bookingAccepted;
      case 'bookingrejected':
      case 'booking_rejected':
        return AppNotificationType.bookingRejected;
      case 'bookingcancelled':
      case 'booking_cancelled':
        return AppNotificationType.bookingCancelled;
      case 'chatmessage':
      case 'chat_message':
        return AppNotificationType.chatMessage;
      default:
        return AppNotificationType.system;
    }
  }

  String get displayName {
    switch (this) {
      case AppNotificationType.bookingRequest:
        return 'Booking Request';
      case AppNotificationType.bookingAccepted:
        return 'Booking Accepted';
      case AppNotificationType.bookingRejected:
        return 'Booking Declined';
      case AppNotificationType.bookingCancelled:
        return 'Booking Cancelled';
      case AppNotificationType.chatMessage:
        return 'New Message';
      case AppNotificationType.system:
        return 'Notification';
    }
  }
}

class AppNotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final AppNotificationType type;
  final String referenceId;
  final bool isRead;
  final DateTime? createdAt;

  const AppNotificationModel({
    this.id = '',
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId = '',
    this.isRead = false,
    this.createdAt,
  });

  factory AppNotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return AppNotificationModel(
      id: docId,
      userId: map['userId'] as String? ?? map['recipientUserId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? map['body'] as String? ?? '',
      type: AppNotificationType.fromString(map['type'] as String?),
      referenceId: map['referenceId'] as String? ?? '',
      isRead: map['isRead'] as bool? ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'recipientUserId': userId,
      'title': title,
      'message': message,
      'body': message,
      'type': type.name,
      'referenceId': referenceId,
      'isRead': isRead,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  AppNotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    AppNotificationType? type,
    String? referenceId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
