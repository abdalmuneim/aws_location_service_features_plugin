import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../error/exceptions.dart';
import 'aws_credentials.dart';

/// Temporary credentials for the unauthenticated role of an Amazon Cognito
/// identity pool, refreshed shortly before they expire.
///
/// Talks to the Cognito Identity JSON API directly (GetId, then
/// GetCredentialsForIdentity), so it runs on every platform including the
/// web. The identity id is kept in shared preferences, so the device keeps
/// the same Cognito identity between launches.
class CognitoCredentialsProvider {
  CognitoCredentialsProvider({
    required this.identityPoolId,
    required http.Client httpClient,
    Future<SharedPreferences> Function()? preferences,
    DateTime Function()? clock,
  }) : _http = httpClient,
       _preferences = preferences ?? SharedPreferences.getInstance,
       _clock = clock ?? DateTime.now;

  final String identityPoolId;
  final http.Client _http;
  final Future<SharedPreferences> Function() _preferences;
  final DateTime Function() _clock;

  static const _refreshMargin = Duration(minutes: 5);
  static const _timeout = Duration(seconds: 30);

  AwsCredentials? _cached;
  Future<AwsCredentials>? _pending;
  String? _identityId;

  /// The region embedded in the pool id (`region:uuid`).
  String get region => identityPoolId.split(':').first;

  /// The Cognito identity id, once [credentials] has run.
  String? get identityId => _identityId;

  String get _identityKey => 'aws_location_service_features.identity_id.$identityPoolId';

  /// Valid credentials, fetching new ones when needed. Concurrent callers
  /// share one request.
  Future<AwsCredentials> credentials() {
    final cached = _cached;
    if (cached != null && !cached.expiresWithin(_refreshMargin, _clock())) {
      return Future.value(cached);
    }
    return _pending ??= _refresh().whenComplete(() => _pending = null);
  }

  /// Drops the cached credentials so the next call fetches new ones.
  void invalidate() => _cached = null;

  Future<AwsCredentials> _refresh() async {
    final prefs = await _preferences();
    var identityId = _identityId ?? prefs.getString(_identityKey);
    try {
      identityId ??= await _getId();
      final credentials = await _getCredentials(identityId);
      _identityId = identityId;
      await prefs.setString(_identityKey, identityId);
      return _cached = credentials;
    } on _CognitoError catch (e) {
      // A stored identity can disappear (pool recreated, identity deleted).
      if (e.type == 'ResourceNotFoundException' && identityId != null) {
        await prefs.remove(_identityKey);
        _identityId = null;
        final fresh = await _getId();
        final credentials = await _getCredentials(fresh);
        _identityId = fresh;
        await prefs.setString(_identityKey, fresh);
        return _cached = credentials;
      }
      throw TrackingException(
        'Cognito sign-in failed: ${e.message}',
        code: FailureCode.cognitoSignInFailed,
        args: {'detail': e.message},
      );
    }
  }

  Future<String> _getId() async {
    final json = await _call('GetId', {'IdentityPoolId': identityPoolId});
    final id = json['IdentityId'];
    if (id is! String || id.isEmpty) {
      throw const _CognitoError('', 'Cognito returned no identity id.');
    }
    return id;
  }

  Future<AwsCredentials> _getCredentials(String identityId) async {
    final json = await _call('GetCredentialsForIdentity', {
      'IdentityId': identityId,
    });
    final c = json['Credentials'];
    if (c is! Map) {
      throw const _CognitoError('', 'Cognito returned no credentials.');
    }
    final expiration = c['Expiration'];
    return AwsCredentials(
      accessKeyId: '${c['AccessKeyId']}',
      secretAccessKey: '${c['SecretKey']}',
      sessionToken: c['SessionToken'] as String?,
      expiration: expiration is num
          ? DateTime.fromMillisecondsSinceEpoch(
              (expiration * 1000).round(),
              isUtc: true,
            )
          : null,
    );
  }

  Future<Map<String, dynamic>> _call(
    String action,
    Map<String, Object?> body,
  ) async {
    final http.Response response;
    try {
      response = await _http
          .post(
            Uri.https('cognito-identity.$region.amazonaws.com', '/'),
            headers: {
              'Content-Type': 'application/x-amz-json-1.1',
              'X-Amz-Target': 'AWSCognitoIdentityService.$action',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const NetworkException(
        'The request timed out.',
        code: FailureCode.requestTimedOut,
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        'Network error: ${e.message}',
        code: FailureCode.networkError,
        args: {'detail': e.message},
      );
    }
    Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      json = decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      json = const {};
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final type = '${json['__type'] ?? ''}'.split('#').last;
      final message =
          (json['message'] ?? json['Message'] ?? 'HTTP ${response.statusCode}')
              .toString();
      throw _CognitoError(type, message);
    }
    return json;
  }
}

class _CognitoError implements Exception {
  const _CognitoError(this.type, this.message);

  final String type;
  final String message;
}
