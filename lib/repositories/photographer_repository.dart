import '../models/photographer_model.dart';
import '../services/photographer_service.dart';

class PhotographerRepository {
  final PhotographerService _service;

  PhotographerRepository({PhotographerService? service})
      : _service = service ?? PhotographerService();

  Stream<List<PhotographerModel>> getPhotographers({String? category}) {
    return _service.streamPhotographers(category: category);
  }

  Future<PhotographerModel?> getPhotographerById(String photographerId) {
    return _service.getPhotographerById(photographerId);
  }

  Future<void> savePhotographer(PhotographerModel photographer) {
    return _service.savePhotographerProfile(photographer);
  }

  Future<void> updateAvailability(String photographerId, bool isAvailable) {
    return _service.updateAvailability(photographerId, isAvailable);
  }

  Stream<Set<String>> getFavorites(String uid) {
    return _service.streamFavorites(uid);
  }

  Future<void> toggleFavorite({
    required String uid,
    required String photographerId,
    required bool isCurrentlySaved,
  }) {
    return _service.toggleFavorite(
      uid: uid,
      photographerId: photographerId,
      isCurrentlySaved: isCurrentlySaved,
    );
  }
}
