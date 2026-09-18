import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/availability_model.dart';
import '../repositories/availability_repository.dart';

class AvailabilityProvider extends ChangeNotifier {
  final AvailabilityRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<AvailabilityModel> _slots = [];
  StreamSubscription<List<AvailabilityModel>>? _subscription;

  AvailabilityProvider({AvailabilityRepository? repository})
      : _repository = repository ?? AvailabilityRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AvailabilityModel> get slots => _slots;

  void streamAvailability(String photographerId) {
    _subscription?.cancel();
    _subscription = _repository.getAvailability(photographerId).listen(
      (items) {
        _slots = items;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> toggleDateAvailability({
    required String photographerId,
    required DateTime date,
    required bool isAvailable,
    String startTime = '09:00 AM',
    String endTime = '06:00 PM',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final slot = AvailabilityModel(
        id: '${photographerId}_${date.year}_${date.month}_${date.day}',
        photographerId: photographerId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        status: isAvailable ? AvailabilityStatus.available : AvailabilityStatus.blocked,
        createdAt: DateTime.now(),
      );

      await _repository.saveAvailability(slot);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
