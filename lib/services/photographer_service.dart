import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exceptions.dart';
import '../models/photographer_model.dart';
import 'firestore_service.dart';

class PhotographerService {
  final FirestoreService _firestoreService;

  PhotographerService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<PhotographerModel>> streamPhotographers({String? category}) {
    if (!_firestoreService.isReady) {
      return Stream.value([]);
    }

    Query<Map<String, dynamic>> query = _firestoreService
        .collection(FirestoreCollections.photographers);

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PhotographerModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<PhotographerModel?> getPhotographerById(String photographerId) async {
    if (!_firestoreService.isReady) return null;
    try {
      final doc = await _firestoreService
          .collection(FirestoreCollections.photographers)
          .doc(photographerId)
          .get();

      if (!doc.exists || doc.data() == null) return null;
      return PhotographerModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw FirestoreException('Failed to get photographer: $e');
    }
  }

  Future<void> savePhotographerProfile(PhotographerModel photographer) async {
    if (!_firestoreService.isReady) {
      throw const FirestoreException('Firestore is not initialized.');
    }
    try {
      final id = photographer.id.isNotEmpty
          ? photographer.id
          : (photographer.uid.isNotEmpty ? photographer.uid : null);

      if (id == null) {
        await _firestoreService
            .collection(FirestoreCollections.photographers)
            .add(photographer.toMap());
      } else {
        await _firestoreService
            .collection(FirestoreCollections.photographers)
            .doc(id)
            .set(photographer.toMap(), SetOptions(merge: true));
      }
    } catch (e) {
      throw FirestoreException('Failed to save photographer profile: $e');
    }
  }

  Future<void> updateAvailability(String photographerId, bool isAvailable) async {
    if (!_firestoreService.isReady) return;
    try {
      await _firestoreService
          .collection(FirestoreCollections.photographers)
          .doc(photographerId)
          .update({
        'isAvailable': isAvailable,
        'acceptingBookings': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Failed to update availability: $e');
    }
  }

  Stream<Set<String>> streamFavorites(String uid) {
    if (!_firestoreService.isReady) {
      return Stream.value({});
    }

    return _firestoreService
        .collection(FirestoreCollections.users)
        .doc(uid)
        .collection(FirestoreCollections.favorites)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  Future<void> toggleFavorite({
    required String uid,
    required String photographerId,
    required bool isCurrentlySaved,
  }) async {
    if (!_firestoreService.isReady) return;
    try {
      final docRef = _firestoreService
          .collection(FirestoreCollections.users)
          .doc(uid)
          .collection(FirestoreCollections.favorites)
          .doc(photographerId);

      if (isCurrentlySaved) {
        await docRef.delete();
      } else {
        await docRef.set({
          'photographerId': photographerId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw FirestoreException('Failed to toggle favorite: $e');
    }
  }
}
