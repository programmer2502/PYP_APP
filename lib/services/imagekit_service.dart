import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../core/errors/app_exceptions.dart';

class ImageKitConfig {
  static const String publicKey = 'public_7ELopVsEjcPXLZ80Yw/6U0VEv8U=';
  static const String privateKey = 'private_Po7pqFLe5HdIbERoeiH5wODFZqQ=';
  static const String urlEndpoint = 'https://ik.imagekit.io/cwudhpweq';
  static const String uploadUrl = 'https://upload.imagekit.io/api/v1/files/upload';
  static const String deleteUrl = 'https://api.imagekit.io/v1/files';
}

class ImageKitUploadResult {
  final String fileId;
  final String name;
  final String url;
  final String? thumbnailUrl;
  final String filePath;
  final String fileType; // 'image', 'non-image'

  const ImageKitUploadResult({
    required this.fileId,
    required this.name,
    required this.url,
    this.thumbnailUrl,
    required this.filePath,
    required this.fileType,
  });

  factory ImageKitUploadResult.fromJson(Map<String, dynamic> json) {
    return ImageKitUploadResult(
      fileId: json['fileId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      filePath: json['filePath'] as String? ?? '',
      fileType: json['fileType'] as String? ?? 'image',
    );
  }
}

class ImageKitService {
  final http.Client _client;

  ImageKitService({http.Client? client}) : _client = client ?? http.Client();

  String get _authHeader {
    final credentials = '${ImageKitConfig.privateKey}:';
    final bytes = utf8.encode(credentials);
    return 'Basic ${base64Encode(bytes)}';
  }

  /// Uploads image bytes to ImageKit
  Future<ImageKitUploadResult> uploadMedia({
    required Uint8List bytes,
    required String fileName,
    String folder = '/pyp',
    List<String>? tags,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(ImageKitConfig.uploadUrl));

      request.headers['Authorization'] = _authHeader;

      // Attach file bytes
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      );
      request.files.add(multipartFile);

      // Metadata fields
      request.fields['fileName'] = fileName;
      request.fields['folder'] = folder;
      request.fields['useUniqueFileName'] = 'true';
      request.fields['isPrivateFile'] = 'false';

      if (tags != null && tags.isNotEmpty) {
        request.fields['tags'] = tags.join(',');
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ImageKitUploadResult.fromJson(data);
      } else {
        String errorMsg = response.body;
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson['message'] != null) {
            errorMsg = errorJson['message'];
          }
        } catch (_) {}
        throw StorageException('ImageKit Upload Failed: $errorMsg');
      }
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('ImageKit Network Error: $e');
    }
  }

  /// Deletes a file from ImageKit by fileId
  Future<void> deleteMedia(String fileId) async {
    if (fileId.isEmpty) return;
    try {
      final url = Uri.parse('${ImageKitConfig.deleteUrl}/$fileId');
      final response = await _client.delete(
        url,
        headers: {'Authorization': _authHeader},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw StorageException('Failed to delete file from ImageKit: ${response.body}');
      }
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('ImageKit Delete Error: $e');
    }
  }
}
