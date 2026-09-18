import 'dart:typed_data';
import '../core/errors/app_exceptions.dart';
import 'imagekit_service.dart';

class StorageService {
  final ImageKitService _imageKitService;

  StorageService({ImageKitService? imageKitService})
      : _imageKitService = imageKitService ?? ImageKitService();

  bool get isReady => true;

  /// Uploads user profile image to ImageKit CDN
  Future<String> uploadProfileImage({
    required String uid,
    required Uint8List imageBytes,
    String contentType = 'image/jpeg',
  }) async {
    try {
      final fileName = 'profile_${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final result = await _imageKitService.uploadMedia(
        bytes: imageBytes,
        fileName: fileName,
        folder: '/pyp/profiles',
        tags: ['profile', uid],
      );

      return result.url;
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Failed to upload profile image: $e');
    }
  }

  /// Uploads photographer portfolio image to ImageKit CDN
  Future<Map<String, String>> uploadPortfolioImage({
    required String photographerId,
    required String portfolioItemId,
    required Uint8List imageBytes,
    String contentType = 'image/jpeg',
  }) async {
    try {
      final fileName = 'portfolio_${photographerId}_$portfolioItemId.jpg';
      final result = await _imageKitService.uploadMedia(
        bytes: imageBytes,
        fileName: fileName,
        folder: '/pyp/portfolios/$photographerId',
        tags: ['portfolio', photographerId],
      );

      return {
        'imageUrl': result.url,
        'storagePath': result.fileId.isNotEmpty ? result.fileId : result.filePath,
        'thumbnailUrl': result.thumbnailUrl ?? result.url,
      };
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Failed to upload portfolio image: $e');
    }
  }

  /// Uploads a promotional or portfolio video to ImageKit CDN
  Future<Map<String, String>> uploadVideo({
    required String photographerId,
    required String videoId,
    required Uint8List videoBytes,
    String fileName = 'video.mp4',
  }) async {
    try {
      final uniqueFileName = 'video_${photographerId}_$videoId.mp4';
      final result = await _imageKitService.uploadMedia(
        bytes: videoBytes,
        fileName: uniqueFileName,
        folder: '/pyp/videos/$photographerId',
        tags: ['video', photographerId],
      );

      return {
        'videoUrl': result.url,
        'fileId': result.fileId,
        'thumbnailUrl': result.thumbnailUrl ?? '',
      };
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Failed to upload video: $e');
    }
  }

  /// Deletes a file from ImageKit by fileId
  Future<void> deleteFile(String fileIdOrPath) async {
    try {
      await _imageKitService.deleteMedia(fileIdOrPath);
    } catch (e) {
      throw StorageException('Failed to delete file from storage: $e');
    }
  }
}
