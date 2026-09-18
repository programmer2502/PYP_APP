import 'dart:typed_data';
import '../core/constants/firestore_collections.dart';
import '../models/portfolio_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class PortfolioRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  PortfolioRepository({
    FirestoreService? firestoreService,
    StorageService? storageService,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _storageService = storageService ?? StorageService();

  Stream<List<PortfolioModel>> getPortfolio(String photographerId) {
    if (!_firestoreService.isReady) return Stream.value([]);
    return _firestoreService
        .collection(FirestoreCollections.portfolios)
        .where('photographerId', isEqualTo: photographerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PortfolioModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<PortfolioModel> addPortfolioItem({
    required String photographerId,
    required String title,
    String description = '',
    required Uint8List imageBytes,
  }) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final uploadResult = await _storageService.uploadPortfolioImage(
      photographerId: photographerId,
      portfolioItemId: tempId,
      imageBytes: imageBytes,
    );

    final portfolio = PortfolioModel(
      id: '',
      photographerId: photographerId,
      title: title,
      description: description,
      imageUrl: uploadResult['imageUrl']!,
      storagePath: uploadResult['storagePath']!,
      createdAt: DateTime.now(),
    );

    final docRef = await _firestoreService
        .collection(FirestoreCollections.portfolios)
        .add(portfolio.toMap());

    return portfolio.copyWith(id: docRef.id);
  }

  Future<void> deletePortfolioItem({
    required String portfolioId,
    required String storagePath,
  }) async {
    if (storagePath.isNotEmpty) {
      await _storageService.deleteFile(storagePath);
    }
    if (_firestoreService.isReady) {
      await _firestoreService
          .collection(FirestoreCollections.portfolios)
          .doc(portfolioId)
          .delete();
    }
  }
}
