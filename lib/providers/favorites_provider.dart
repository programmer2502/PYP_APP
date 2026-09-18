import 'dart:async';
import 'package:flutter/foundation.dart';
import '../repositories/photographer_repository.dart';

class FavoritesProvider extends ChangeNotifier {
  final PhotographerRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  Set<String> _favoriteIds = {};
  StreamSubscription<Set<String>>? _subscription;

  FavoritesProvider({PhotographerRepository? repository})
      : _repository = repository ?? PhotographerRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<String> get favoriteIds => _favoriteIds;

  bool isFavorite(String photographerId) => _favoriteIds.contains(photographerId);

  void streamFavorites(String uid) {
    _subscription?.cancel();
    _subscription = _repository.getFavorites(uid).listen(
      (items) {
        _favoriteIds = items;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> toggleFavorite({
    required String uid,
    required String photographerId,
  }) async {
    final isSaved = _favoriteIds.contains(photographerId);
    if (isSaved) {
      _favoriteIds.remove(photographerId);
    } else {
      _favoriteIds.add(photographerId);
    }
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.toggleFavorite(
        uid: uid,
        photographerId: photographerId,
        isCurrentlySaved: isSaved,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }


  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
