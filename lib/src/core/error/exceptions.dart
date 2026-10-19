import 'failures.dart';

export 'failures.dart' show ErrorCode, FailureCode;

/// Exceptions thrown by data sources. Repositories convert them into
/// failures so the domain and presentation layers never see them.
///
/// [code] and [args] are carried over to the failure (see [ErrorCode]).
class ServerException implements Exception {
  const ServerException({
    required this.statusCode,
    required this.message,
    this.reason,
    this.fieldErrors = const [],
    this.code,
    this.args = const {},
    this.signed = false,
  });

  final int statusCode;
  final String message;
  final String? reason;
  final List<String> fieldErrors;

  /// Set only when the response had no message of its own.
  final ErrorCode? code;
  final Map<String, Object> args;

  /// True when the request was signed with AWS credentials (SigV4) rather
  /// than authorized by an API key.
  final bool signed;

  @override
  String toString() => 'ServerException($statusCode, $message)';
}

class NetworkException implements Exception {
  const NetworkException(this.message, {this.code, this.args = const {}});

  final String message;
  final ErrorCode? code;
  final Map<String, Object> args;

  @override
  String toString() => 'NetworkException($message)';
}

class LocationPermissionException implements Exception {
  const LocationPermissionException(
    this.message, {
    this.code,
    this.args = const {},
  });

  final String message;
  final ErrorCode? code;
  final Map<String, Object> args;

  @override
  String toString() => 'LocationPermissionException($message)';
}

class CacheException implements Exception {
  const CacheException(this.message, {this.code, this.args = const {}});

  final String message;
  final ErrorCode? code;
  final Map<String, Object> args;

  @override
  String toString() => 'CacheException($message)';
}

/// Raised by cloud tracking (native SDKs or the web implementation).
class TrackingException implements Exception {
  const TrackingException(this.message, {this.code, this.args = const {}});

  final String message;
  final ErrorCode? code;
  final Map<String, Object> args;

  @override
  String toString() => 'TrackingException($message)';
}
