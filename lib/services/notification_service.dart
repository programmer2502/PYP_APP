import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'firestore_service.dart';

class NotificationService {
  final FirestoreService _firestoreService;

  NotificationService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<AppNotificationModel>> streamNotifications(List<String> userIdentifiers) {
    if (!_firestoreService.isReady || userIdentifiers.isEmpty) {
      return Stream.value([]);
    }

    final cleanIdentifiers = userIdentifiers
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty && s != 'user@example.com' && s != 'pyp user')
        .toSet();

    if (cleanIdentifiers.isEmpty) {
      return Stream.value([]);
    }

    return _firestoreService
        .collection('notifications')
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => AppNotificationModel.fromMap(doc.data(), doc.id))
              .where((n) {
                final uid = n.userId.trim().toLowerCase();
                return cleanIdentifiers.contains(uid);
              })
              .toList();

          list.sort((a, b) {
            final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });

          return list;
        });
  }

  Future<String?> sendNotification({
    required String recipientUserId,
    required String title,
    required String message,
    required AppNotificationType type,
    String referenceId = '',
  }) async {
    if (!_firestoreService.isReady) return null;

    try {
      final docRef = await _firestoreService.collection('notifications').add({
        'userId': recipientUserId,
        'recipientUserId': recipientUserId,
        'title': title,
        'message': message,
        'body': message,
        'type': type.name,
        'referenceId': referenceId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (_) {
      return null;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    if (!_firestoreService.isReady || notificationId.isEmpty) return;

    try {
      await _firestoreService
          .collection('notifications')
          .doc(notificationId)
          .update({
        'isRead': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}
