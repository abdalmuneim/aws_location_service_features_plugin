import 'package:equatable/equatable.dart';

/// Temporary AWS credentials, e.g. from an Amazon Cognito identity pool.
class AwsCredentials extends Equatable {
  const AwsCredentials({
    required this.accessKeyId,
    required this.secretAccessKey,
    this.sessionToken,
    this.expiration,
  });

  final String accessKeyId;
  final String secretAccessKey;
  final String? sessionToken;
  final DateTime? expiration;

  /// True when the credentials expire within [margin] of [now].
  bool expiresWithin(Duration margin, DateTime now) {
    final expiration = this.expiration;
    return expiration != null && !now.add(margin).isBefore(expiration);
  }

  @override
  List<Object?> get props => [
    accessKeyId,
    secretAccessKey,
    sessionToken,
    expiration,
  ];

  @override
  String toString() => 'AwsCredentials($accessKeyId, expires $expiration)';
}
