import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'aws_credentials.dart';

/// AWS Signature Version 4 request signing.
///
/// Amazon Location resources that don't accept API keys (trackers,
/// geofence collections) need signed requests; the signing service name is
/// `geo`.
class SigV4Signer {
  const SigV4Signer({required this.region, this.service = 'geo'});

  final String region;
  final String service;

  static const _algorithm = 'AWS4-HMAC-SHA256';

  /// Returns [headers] plus `Host`, `X-Amz-Date`, `X-Amz-Security-Token`
  /// (when the credentials have a session token) and `Authorization`.
  ///
  /// [uri] must be the exact URL that is sent. Every header in [headers] is
  /// signed, so pass only headers that reach AWS unchanged.
  Map<String, String> sign({
    required String method,
    required Uri uri,
    required AwsCredentials credentials,
    Map<String, String> headers = const {},
    List<int> body = const [],
    DateTime? now,
  }) {
    final time = (now ?? DateTime.now()).toUtc();
    final amzDate = _amzDate(time);
    final date = amzDate.substring(0, 8);

    final signed = <String, String>{
      for (final e in headers.entries) e.key.toLowerCase(): e.value,
      'host': uri.hasPort && !_isDefaultPort(uri)
          ? '${uri.host}:${uri.port}'
          : uri.host,
      'x-amz-date': amzDate,
      if (credentials.sessionToken != null)
        'x-amz-security-token': credentials.sessionToken!,
    };
    final names = signed.keys.toList()..sort();
    final canonicalHeaders = names
        .map((n) => '$n:${_trimAll(signed[n]!)}\n')
        .join();
    final signedHeaders = names.join(';');

    final canonicalRequest = [
      method.toUpperCase(),
      _canonicalPath(uri),
      _canonicalQuery(uri),
      canonicalHeaders,
      signedHeaders,
      sha256.convert(body).toString(),
    ].join('\n');

    final scope = '$date/$region/$service/aws4_request';
    final stringToSign = [
      _algorithm,
      amzDate,
      scope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');

    var key = _hmac(utf8.encode('AWS4${credentials.secretAccessKey}'), date);
    key = _hmac(key, region);
    key = _hmac(key, service);
    key = _hmac(key, 'aws4_request');
    final signature = Hmac(
      sha256,
      key,
    ).convert(utf8.encode(stringToSign)).toString();

    return {
      ...headers,
      'X-Amz-Date': amzDate,
      if (credentials.sessionToken != null)
        'X-Amz-Security-Token': credentials.sessionToken!,
      'Authorization':
          '$_algorithm Credential=${credentials.accessKeyId}/$scope, '
          'SignedHeaders=$signedHeaders, Signature=$signature',
    };
  }

  static List<int> _hmac(List<int> key, String data) =>
      Hmac(sha256, key).convert(utf8.encode(data)).bytes;

  static bool _isDefaultPort(Uri uri) =>
      (uri.scheme == 'https' && uri.port == 443) ||
      (uri.scheme == 'http' && uri.port == 80);

  static String _amzDate(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year.toString().padLeft(4, '0')}${two(t.month)}${two(t.day)}'
        'T${two(t.hour)}${two(t.minute)}${two(t.second)}Z';
  }

  static String _trimAll(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Non-S3 services encode each path segment twice: once for the wire and
  /// once more in the canonical request.
  static String _canonicalPath(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.isEmpty) return '/';
    final path = segments.map((s) => _encode(_encode(s))).join('/');
    return '/$path';
  }

  static String _canonicalQuery(Uri uri) {
    final pairs = <MapEntry<String, String>>[];
    uri.queryParametersAll.forEach((key, values) {
      for (final value in values) {
        pairs.add(MapEntry(_encode(key), _encode(value)));
      }
    });
    pairs.sort((a, b) {
      final byKey = a.key.compareTo(b.key);
      return byKey != 0 ? byKey : a.value.compareTo(b.value);
    });
    return pairs.map((p) => '${p.key}=${p.value}').join('&');
  }

  /// RFC 3986 percent-encoding of everything except unreserved characters.
  static String _encode(String value) {
    final out = StringBuffer();
    for (final byte in utf8.encode(value)) {
      final unreserved =
          (byte >= 0x41 && byte <= 0x5A) || // A-Z
          (byte >= 0x61 && byte <= 0x7A) || // a-z
          (byte >= 0x30 && byte <= 0x39) || // 0-9
          byte == 0x2D || // -
          byte == 0x2E || // .
          byte == 0x5F || // _
          byte == 0x7E; // ~
      if (unreserved) {
        out.writeCharCode(byte);
      } else {
        out.write('%${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}');
      }
    }
    return out.toString();
  }
}
