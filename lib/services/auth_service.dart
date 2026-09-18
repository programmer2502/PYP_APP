import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import '../core/errors/app_exceptions.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class AuthService {
  final FirebaseAuth? _customAuth;

  AuthService({FirebaseAuth? auth}) : _customAuth = auth;

  FirebaseAuth get _auth => _customAuth ?? FirebaseAuth.instance;

  User? get currentUser {
    if (!FirebaseService.instance.isInitialized && _customAuth == null) return null;
    return _auth.currentUser;
  }

  Stream<User?> get authStateChanges {
    if (!FirebaseService.instance.isInitialized && _customAuth == null) {
      return Stream.value(null);
    }
    return _auth.authStateChanges();
  }

  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    if (!FirebaseService.instance.isInitialized) {
      throw const AuthException('Firebase is not configured. Please supply Firebase credentials.');
    }
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      developer.log('Signup error: ${e.code}', name: 'AuthService', error: e);
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException('Failed to sign up: $e');
    }
  }

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (!FirebaseService.instance.isInitialized) {
      throw const AuthException('Firebase is not configured. Please supply Firebase credentials.');
    }
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      developer.log('Login error: ${e.code}', name: 'AuthService', error: e);
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    if (!FirebaseService.instance.isInitialized) return;
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (!FirebaseService.instance.isInitialized) {
      throw const AuthException('Firebase is not configured.');
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException('Failed to send password reset email: $e');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    // Architectural preparation for Google Sign-In:
    // Requires SHA-1 fingerprint and google_sign_in package configuration.
    if (!FirebaseService.instance.isInitialized) {
      throw const AuthException('Firebase is not configured.');
    }
    throw const AuthException(
      'Google Sign-In requires SHA-1 fingerprint configuration in Firebase Console.',
      code: 'GOOGLE_SIGN_IN_PENDING_CONFIG',
    );
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
