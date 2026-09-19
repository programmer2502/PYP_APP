import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/errors/app_exceptions.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class AuthService {
  final FirebaseAuth? _customAuth;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _customAuth = auth,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

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
    try {
      await _googleSignIn.signOut().catchError((_) => null);
    } catch (_) {}

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
    if (!FirebaseService.instance.isInitialized) {
      throw const AuthException('Firebase is not configured. Please supply Firebase credentials.');
    }
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException(
          'Google sign-in was cancelled.',
          code: 'SIGN_IN_CANCELLED',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      developer.log('Google Sign-In Auth Error: ${e.code}', name: 'AuthService', error: e);
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      developer.log('Google Sign-In Error: $e', name: 'AuthService', error: e);
      throw AuthException('Failed to sign in with Google: $e');
    }
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
