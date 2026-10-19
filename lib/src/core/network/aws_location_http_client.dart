import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/aws_location_config.dart';
import '../error/exceptions.dart';
import '../utils/json_utils.dart';

/// The three Amazon Location v2 service endpoints reachable with an API key.
enum AwsLocationService {
  maps('maps'),
  places('places'),
  routes('routes');

  const AwsLocationService(this.host);

  final String host;
}

/// Thin HTTP client for Amazon Location Service authenticated by API key.
///
/// Every request goes to `https://{service}.geo.{region}.amazonaws.com/v2`
/// with the key appended as the `key` query parameter. Non-2xx responses
/// are turned into [ServerException]s and transport errors into
/// [NetworkException]s.
class AwsLocationHttpClient {
  AwsLocationHttpClient(this._http, this._config);

  final http.Client _http;
  final AwsLocationConfig _config;

  static const _timeout = Duration(seconds: 30);

  String get region => _config.region;

  /// Builds an endpoint URL. List values become repeated query parameters
  /// and null or empty values are skipped.
  Uri buildUri(
    AwsLocationService service,
    String path, [
    Map<String, Object?> query = const {},
  ]) {
    final params = <String, dynamic>{};
    query.forEach((key, value) {
      if (value == null) return;
      if (value is Iterable) {
        final values = value.map((e) => '$e').toList();
        if (values.isNotEmpty) params[key] = values;
      } else {
        final text = '$value';
        if (text.isNotEmpty) params[key] = text;
      }
    });
    params['key'] = _config.apiKey;
    return Uri.https(
      '${service.host}.geo.${_config.region}.amazonaws.com',
      '/v2$path',
      params,
    );
  }

  Future<Map<String, dynamic>> postJson(
    AwsLocationService service,
    String path,
    Map<String, Object?> body,
  ) async {
    final uri = buildUri(service, path);
    final payload = jsonEncode(JsonUtils.compact(body));
    final response = await _send(
      () => _http.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: payload,
      ),
    );
    return _decodeJson(response);
  }

  Future<Map<String, dynamic>> getJson(
    AwsLocationService service,
    String path, [
    Map<String, Object?> query = const {},
  ]) async {
    final response = await _send(
      () => _http.get(buildUri(service, path, query)),
    );
    return _decodeJson(response);
  }

  Future<Uint8List> getBytes(Uri uri) async {
    final response = await _send(() => _http.get(uri));
    return response.bodyBytes;
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
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
    } catch (e) {
      throw NetworkException(
        'Network error: $e',
        code: FailureCode.networkError,
        args: {'detail': '$e'},
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _toServerException(response);
    }
    return response;
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    if (response.bodyBytes.isEmpty) return const {};
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return decoded is Map<String, dynamic> ? decoded : {'value': decoded};
  }

  ServerException _toServerException(http.Response response) {
    String? serverMessage;
    String? reason;
    final fields = <String>[];
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map) {
        serverMessage = (body['message'] ?? body['Message'])?.toString();
        reason = body['reason']?.toString();
        final list = body['fieldList'];
        if (list is List) {
          for (final f in list) {
            if (f is Map) fields.add('${f['name']}: ${f['message']}');
          }
        }
      }
    } catch (_) {
      // Body was not JSON; keep the generic message.
    }
    final message =
        serverMessage ?? 'Request failed with HTTP ${response.statusCode}.';
    if (kDebugMode) {
      debugPrint(
        'AWS ${response.statusCode} ${response.request?.url.path}: '
        '$message',
      );
    }
    return ServerException(
      statusCode: response.statusCode,
      message: message,
      reason: reason,
      fieldErrors: fields,
      code: serverMessage == null ? FailureCode.httpStatus : null,
      args: {'status': response.statusCode},
    );
  }
}
