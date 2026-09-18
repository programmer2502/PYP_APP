import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        developer.log('Firebase already initialized.', name: 'FirebaseService');
        return;
      }

      await Firebase.initializeApp();
      _isInitialized = true;
      developer.log('Firebase initialized successfully.', name: 'FirebaseService');
    } catch (e, stack) {
      developer.log(
        'Firebase initialization warning: $e\n'
        'The application will proceed with mock/offline fallback until firebase_options.dart / google-services.json are configured.',
        name: 'FirebaseService',
        error: e,
        stackTrace: stack,
      );
      _isInitialized = false;
    }
  }
}
