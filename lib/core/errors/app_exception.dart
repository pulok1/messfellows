/// Base type for errors the UI is expected to catch and translate into a
/// friendly message, instead of letting raw database/platform exceptions
/// reach the user.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// A write was rejected because the input violated a domain rule (e.g. an
/// empty member name, a negative amount, a duplicate meal record).
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// A local database read/write failed unexpectedly.
class StorageException extends AppException {
  const StorageException(super.message);
}

/// An import file was missing, malformed, or from an incompatible schema
/// version.
class ImportException extends AppException {
  const ImportException(super.message);
}
