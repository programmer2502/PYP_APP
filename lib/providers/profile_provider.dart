import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  final StorageService _storageService;

  UserModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileProvider({
    UserRepository? userRepository,
    StorageService? storageService,
  })  : _userRepository = userRepository ?? UserRepository(),
        _storageService = storageService ?? StorageService();

  UserModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setProfile(UserModel? user) {
    _profile = user;
    notifyListeners();
  }

  Future<void> fetchProfile(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _userRepository.getUser(uid);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<UserModel?> streamProfile(String uid) {
    return _userRepository.streamUser(uid);
  }

  Future<bool> updateProfile({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String city,
    UserRole? role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = UserModel(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        city: city,
        role: role ?? _profile?.role ?? UserRole.customer,
        profileImageUrl: _profile?.profileImageUrl,
        updatedAt: DateTime.now(),
      );

      await _userRepository.createOrUpdateUser(updated);
      _profile = updated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> uploadProfileImage({
    required String uid,
    required Uint8List imageBytes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final imageUrl = await _storageService.uploadProfileImage(
        uid: uid,
        imageBytes: imageBytes,
      );

      if (_profile != null) {
        final updated = _profile!.copyWith(profileImageUrl: imageUrl);
        await _userRepository.createOrUpdateUser(updated);
        _profile = updated;
      }

      _isLoading = false;
      notifyListeners();
      return imageUrl;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
