class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.details});
}

class FirestoreException extends AppException {
  const FirestoreException(super.message, {super.code, super.details});
}

class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.details});
}

class BookingConflictException extends AppException {
  const BookingConflictException(
    super.message, {
    super.code = 'DOUBLE_BOOKING',
    super.details,
  });
}
