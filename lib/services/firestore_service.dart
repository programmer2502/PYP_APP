import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/app_exceptions.dart';
import 'firebase_service.dart';

class FirestoreService {
  final FirebaseFirestore? _customFirestore;

  FirestoreService({FirebaseFirestore? firestore}) : _customFirestore = firestore;

  FirebaseFirestore get instance => _customFirestore ?? FirebaseFirestore.instance;

  bool get isReady => FirebaseService.instance.isInitialized || _customFirestore != null;

  CollectionReference<Map<String, dynamic>> collection(String path) {
    if (!isReady) {
      throw const FirestoreException('Firestore is not initialized.');
    }
    return instance.collection(path);
  }

  DocumentReference<Map<String, dynamic>> doc(String path) {
    if (!isReady) {
      throw const FirestoreException('Firestore is not initialized.');
    }
    return instance.doc(path);
  }

  Future<T> runTransaction<T>(TransactionHandler<T> updateFunction) async {
    if (!isReady) {
      throw const FirestoreException('Firestore is not initialized.');
    }
    return instance.runTransaction(updateFunction);
  }

  WriteBatch batch() {
    if (!isReady) {
      throw const FirestoreException('Firestore is not initialized.');
    }
    return instance.batch();
  }
}
