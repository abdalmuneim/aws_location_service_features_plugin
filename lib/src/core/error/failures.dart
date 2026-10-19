import 'package:equatable/equatable.dart';

/// Identifies a failure so an app can describe it in the user's language.
///
/// The plugin's own codes are the [FailureCode] values. Apps can declare
/// further codes with their own enum that implements this interface:
///
/// ```dart
/// enum AppFailureCode implements ErrorCode { settingsNotSaved }
/// ```
abstract interface class ErrorCode {}

/// Failures the plugin raises itself. Failures carrying a message from the
/// API have no code; show that message as it is.
enum FailureCode implements ErrorCode {
  requestTimedOut,
  networkError,
  httpStatus,

  /// The API key was rejected (HTTP 401/403). Args: `status`, `detail`.
  apiKeyRejected,

  /// Signed (Cognito/IAM) credentials were rejected or lack a permission.
  /// Args: `status`, `detail`.
  credentialsRejected,
  notFound,
  tooManyRequests,
  locationServicesOff,
  locationPermissionDenied,
  locationPermissionDeniedForever,
  geofencesNotRead,
  geofencesNotSaved,
  geocodeAddressRequired,
  searchQueryRequired,
  geofenceNameRequired,
  geofencePolygonTooFewPoints,
  geofenceRadiusNotPositive,
  isolineThresholdRequired,
  isolineTooManyThresholds,
  routeSameOriginAndDestination,
  routeTooManyStops,
  matrixPointsRequired,
  matrixTooManyPoints,
  optimizeStopsRequired,
  optimizeTooManyStops,
  snapTooFewPoints,
  snapTooManyPoints,

  /// Cloud tracking needs an identity pool id and a tracker name.
  trackerConfigIncomplete,

  /// The identity pool id is not of the form `region:uuid`.
  identityPoolIdInvalid,

  /// A cloud tracking call was made before `configure`.
  trackerNotConfigured,

  /// Background tracking is not available on this platform (the web).
  backgroundTrackingUnsupported,

  /// Cognito did not return credentials. Args: `detail`.
  cognitoSignInFailed,

  /// The native tracking SDK reported an error. Args: `detail`.
  trackingPlatformError,
}

/// A recoverable error, returned from repositories inside a `Result`.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.code, this.args = const {}});

  /// English description, used for logs and whenever [code] is null.
  final String message;

  final ErrorCode? code;

  /// Values for the translated message, e.g. `{'max': 25}`.
  final Map<String, Object> args;

  @override
  List<Object?> get props => [message, code, args];
}

/// The key or credentials are missing, invalid, expired, or not allowed to
/// call the action.
final class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.args});
}

/// The request was rejected by validation (HTTP 400, or a use case check).
final class ValidationFailure extends Failure {
  const ValidationFailure(
    super.message, {
    super.code,
    super.args,
    this.fieldErrors = const [],
  });

  final List<String> fieldErrors;

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.args, this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [...super.props, statusCode];
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.args});
}

final class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code, super.args});
}

final class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code, super.args});
}

/// Cloud tracking could not run (not configured, unsupported, SDK error).
final class TrackingFailure extends Failure {
  const TrackingFailure(super.message, {super.code, super.args});
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
