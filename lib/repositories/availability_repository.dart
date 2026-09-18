import '../models/availability_model.dart';
import '../services/availability_service.dart';

class AvailabilityRepository {
  final AvailabilityService _service;

  AvailabilityRepository({AvailabilityService? service})
      : _service = service ?? AvailabilityService();

  Stream<List<AvailabilityModel>> getAvailability(String photographerId) {
    return _service.streamAvailability(photographerId);
  }

  Future<void> saveAvailability(AvailabilityModel model) {
    return _service.setAvailabilitySlot(model);
  }

  Future<void> removeAvailabilitySlot(String slotId) {
    return _service.deleteAvailabilitySlot(slotId);
  }
}
