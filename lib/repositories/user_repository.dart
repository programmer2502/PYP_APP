import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exceptions.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserRepository {
  final FirestoreService _firestoreService;

  UserRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<UserModel?> getUser(String uid) async {
    if (!_firestoreService.isReady) return null;
    try {
      final doc = await _firestoreService
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();

      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw FirestoreException('Failed to fetch user: $e');
    }
  }

  Stream<UserModel?> streamUser(String uid) {
    if (!_firestoreService.isReady) return Stream.value(null);
    return _firestoreService
        .collection(FirestoreCollections.users)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    });
  }

  Future<void> createOrUpdateUser(UserModel user) async {
    if (!_firestoreService.isReady) return;
    try {
      await _firestoreService
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to update user profile: $e');
    }
  }
}
