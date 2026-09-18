import 'package:flutter/foundation.dart';
import '../models/portfolio_model.dart';
import '../repositories/portfolio_repository.dart';

class PortfolioProvider extends ChangeNotifier {
  final PortfolioRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<PortfolioModel> _items = [];

  PortfolioProvider({PortfolioRepository? repository})
      : _repository = repository ?? PortfolioRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PortfolioModel> get items => _items;

  void streamPortfolio(String photographerId) {
    _repository.getPortfolio(photographerId).listen(
      (data) {
        _items = data;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  Future<PortfolioModel?> uploadPortfolioWork({
    required String photographerId,
    required String title,
    String description = '',
    required Uint8List imageBytes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _repository.addPortfolioItem(
        photographerId: photographerId,
        title: title,
        description: description,
        imageBytes: imageBytes,
      );
      _items.insert(0, created);
      _isLoading = false;
      notifyListeners();
      return created;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> deletePortfolioWork({
    required String portfolioId,
    required String storagePath,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.deletePortfolioItem(
        portfolioId: portfolioId,
        storagePath: storagePath,
      );
      _items.removeWhere((item) => item.id == portfolioId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
