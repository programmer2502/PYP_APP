import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../repositories/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepository;

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    AuthService? authService,
    UserRepository? userRepository,
  })  : _authService = authService ?? AuthService(),
        _userRepository = userRepository ?? UserRepository() {
    _init();
  }

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _init() {
    _authService.authStateChanges.listen((user) async {
      _firebaseUser = user;
      if (user != null) {
        // Immediate baseline model from Firebase User
        _userModel = UserModel(
          uid: user.uid,
          name: user.displayName?.isNotEmpty == true
              ? user.displayName!
              : (user.email?.split('@').first ?? 'PYP User'),
          email: user.email ?? '',
          phone: user.phoneNumber ?? '',
          role: UserRole.customer,
          profileImageUrl: user.photoURL,
          createdAt: DateTime.now(),
        );
        notifyListeners();

        try {
          final fetched = await _userRepository.getUser(user.uid);
          if (fetched != null) {
            _userModel = fetched;
            notifyListeners();
          } else if (_userModel != null) {
            _userRepository.createOrUpdateUser(_userModel!).catchError((_) {});
          }
        } catch (_) {}
      } else {
        _userModel = null;
        notifyListeners();
      }
    });
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        _userModel = await _userRepository.getUser(credential.user!.uid);
      }
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

  Future<bool> signup({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String city = 'Bengaluru',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
        name: name,
        role: role,
      );

      if (credential.user != null) {
        final newUser = UserModel(
          uid: credential.user!.uid,
          name: name,
          email: email,
          city: city,
          role: role,
          createdAt: DateTime.now(),
        );
        await _userRepository.createOrUpdateUser(newUser);
        _userModel = newUser;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '').replaceFirst('AuthException: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle({UserRole role = UserRole.customer}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signInWithGoogle();
      if (credential.user != null) {
        final user = credential.user!;
        final existingUser = await _userRepository.getUser(user.uid);
        if (existingUser == null) {
          final newUser = UserModel(
            uid: user.uid,
            name: user.displayName?.isNotEmpty == true
                ? user.displayName!
                : (user.email?.split('@').first ?? 'PYP User'),
            email: user.email ?? '',
            phone: user.phoneNumber ?? '',
            role: role,
            profileImageUrl: user.photoURL,
            createdAt: DateTime.now(),
          );
          await _userRepository.createOrUpdateUser(newUser);
          _userModel = newUser;
        } else {
          _userModel = existingUser;
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '').replaceFirst('AuthException: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _firebaseUser = null;
    _userModel = null;
    notifyListeners();
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
