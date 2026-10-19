import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../auth/aws_credentials.dart';
import '../auth/sigv4_signer.dart';
import '../error/exceptions.dart';
import '../utils/json_utils.dart';

/// JSON client for Amazon Location APIs that need SigV4-signed requests
/// (trackers, geofence collections), with credentials from [credentials].
class AwsSignedHttpClient {
  AwsSignedHttpClient({
    required http.Client httpClient,
    required this.region,
    required this.credentials,
    DateTime Function()? clock,
  }) : _http = httpClient,
       _clock = clock ?? DateTime.now,
       _signer = SigV4Signer(region: region);

  final http.Client _http;
  final String region;

  /// Called before every request; return cached credentials when valid.
  final Future<AwsCredentials> Function() credentials;
  final DateTime Function() _clock;
  final SigV4Signer _signer;

  static const _timeout = Duration(seconds: 30);

  /// `https://{prefix}.geo.{region}.amazonaws.com{path}`, e.g. prefix
  /// `tracking` or `geofencing`.
  Uri uri(String prefix, String path) =>
      Uri.https('$prefix.geo.$region.amazonaws.com', path);

  Future<Map<String, dynamic>> postJson(Uri uri, Map<String, Object?> body) =>
      _send('POST', uri, utf8.encode(jsonEncode(JsonUtils.compact(body))));

  Future<Map<String, dynamic>> getJson(Uri uri) => _send('GET', uri, const []);

  Future<Map<String, dynamic>> _send(
    String method,
    Uri uri,
    List<int> body,
  ) async {
    final headers = _signer.sign(
      method: method,
      uri: uri,
      credentials: await credentials(),
      headers: {if (body.isNotEmpty) 'Content-Type': 'application/json'},
      body: body,
      now: _clock(),
    );
    // Browsers set Host themselves and refuse a script-provided one.
    final request = http.Request(method, uri)
      ..headers.addAll(headers)
      ..bodyBytes = body;
    final http.Response response;
    try {
      response = await http.Response.fromStream(await _http.send(request))
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
    final decoded = response.bodyBytes.isEmpty
        ? const <String, dynamic>{}
        : _tryDecode(response.bodyBytes);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          (decoded['message'] ??
                  decoded['Message'] ??
                  'Request failed with HTTP ${response.statusCode}.')
              .toString();
      if (kDebugMode) {
        debugPrint('AWS ${response.statusCode} ${uri.path}: $message');
      }
      throw ServerException(
        statusCode: response.statusCode,
        message: message,
        signed: true,
        code: decoded.isEmpty ? FailureCode.httpStatus : null,
        args: {'status': response.statusCode},
      );
    }
    return decoded;
  }

  static Map<String, dynamic> _tryDecode(List<int> bytes) {
    try {
      final value = jsonDecode(utf8.decode(bytes));
      return value is Map<String, dynamic> ? value : {'value': value};
    } catch (_) {
      return const {};
    }
  }
}
