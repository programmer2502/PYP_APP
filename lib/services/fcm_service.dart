import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_collections.dart';
import 'firestore_service.dart';

enum NotificationType {
  bookingRequest,
  bookingAccepted,
  bookingRejected,
  bookingCancelled,
  chatMessage,
  paymentConfirmed,
}

class NotificationPayload {
  final String title;
  final String body;
  final NotificationType type;
  final String referenceId; // bookingId or conversationId
  final Map<String, dynamic> data;

  const NotificationPayload({
    required this.title,
    required this.body,
    required this.type,
    required this.referenceId,
    this.data = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type.name,
      'referenceId': referenceId,
      'data': data,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class FCMService {
  final FirestoreService _firestoreService;

  FCMService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<void> saveUserFcmToken(String userId, String token) async {
    if (!_firestoreService.isReady) return;

    try {
      await _firestoreService
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection('fcmTokens')
          .doc(token)
          .set({
        'token': token,
        'platform': 'flutter',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> queueNotification({
    required String recipientUserId,
    required NotificationPayload payload,
  }) async {
    if (!_firestoreService.isReady) return;

    try {
      await _firestoreService
          .collection(FirestoreCollections.users)
          .doc(recipientUserId)
          .collection('notifications')
          .add(payload.toMap());
    } catch (_) {}
  }
}
