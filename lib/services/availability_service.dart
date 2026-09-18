import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exceptions.dart';
import '../models/availability_model.dart';
import 'firestore_service.dart';

class AvailabilityService {
  final FirestoreService _firestoreService;

  AvailabilityService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<AvailabilityModel>> streamAvailability(String photographerId) {
    if (!_firestoreService.isReady) {
      return Stream.value([]);
    }

    return _firestoreService
        .collection(FirestoreCollections.availability)
        .where('photographerId', isEqualTo: photographerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AvailabilityModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> setAvailabilitySlot(AvailabilityModel model) async {
    if (!_firestoreService.isReady) return;
    try {
      if (model.id.isNotEmpty) {
        await _firestoreService
            .collection(FirestoreCollections.availability)
            .doc(model.id)
            .set(model.toMap(), SetOptions(merge: true));
      } else {
        await _firestoreService
            .collection(FirestoreCollections.availability)
            .add(model.toMap());
      }
    } catch (e) {
      throw FirestoreException('Failed to set availability: $e');
    }
  }

  Future<void> deleteAvailabilitySlot(String slotId) async {
    if (!_firestoreService.isReady) return;
    try {
      await _firestoreService
          .collection(FirestoreCollections.availability)
          .doc(slotId)
          .delete();
    } catch (e) {
      throw FirestoreException('Failed to delete availability slot: $e');
    }
  }
}
