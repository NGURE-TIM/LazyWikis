/// Base exception for LazyWikis
abstract class LazyWikisException implements Exception {
  final String message;
  final dynamic originalError;

  LazyWikisException(this.message, [this.originalError]);

  @override
  String toString() => message;
}

/// Thrown when storage operations fail
class StorageException extends LazyWikisException {
  StorageException(super.message, [super.originalError]);
}

/// Thrown when validation fails
class ValidationException extends LazyWikisException {
  ValidationException(super.message);
}

/// Thrown when API calls fail
class ApiException extends LazyWikisException {
  final int? statusCode;

  ApiException(String message, {this.statusCode, dynamic error})
    : super(message, error);
}
