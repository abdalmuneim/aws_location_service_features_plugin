import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test vectors from the AWS Signature Version 4 documentation and test
/// suite (credentials AKIDEXAMPLE, 2015-08-30T12:36:00Z, us-east-1).
void main() {
  const credentials = AwsCredentials(
    accessKeyId: 'AKIDEXAMPLE',
    secretAccessKey: 'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY',
  );
  final now = DateTime.utc(2015, 8, 30, 12, 36);

  String authorization(Map<String, String> headers) =>
      headers['Authorization']!;

  test('get-vanilla', () {
    final headers = const SigV4Signer(region: 'us-east-1', service: 'service')
        .sign(
          method: 'GET',
          uri: Uri.parse('https://example.amazonaws.com/'),
          credentials: credentials,
          now: now,
        );
    expect(headers['X-Amz-Date'], '20150830T123600Z');
    expect(
      authorization(headers),
      'AWS4-HMAC-SHA256 '
      'Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, '
      'SignedHeaders=host;x-amz-date, '
      'Signature=5fa00fa31553b73ebf1942676e86291e8372ff2a2260956d9b8aae1d763fbf31',
    );
  });

  test('post-vanilla', () {
    final headers = const SigV4Signer(region: 'us-east-1', service: 'service')
        .sign(
          method: 'POST',
          uri: Uri.parse('https://example.amazonaws.com/'),
          credentials: credentials,
          now: now,
        );
    expect(
      authorization(headers),
      endsWith(
        'Signature=5da7c1a2acd57cee7505fc6676e4e544621c30862966e37dddb68e92efbe5d6b',
      ),
    );
  });

  test('IAM ListUsers with a query string and content type', () {
    final headers = const SigV4Signer(region: 'us-east-1', service: 'iam').sign(
      method: 'GET',
      uri: Uri.parse(
        'https://iam.amazonaws.com/?Action=ListUsers&Version=2010-05-08',
      ),
      credentials: credentials,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
      },
      now: now,
    );
    expect(
      authorization(headers),
      'AWS4-HMAC-SHA256 '
      'Credential=AKIDEXAMPLE/20150830/us-east-1/iam/aws4_request, '
      'SignedHeaders=content-type;host;x-amz-date, '
      'Signature=5d672d79c15b13162d9279b0855cfba6789a8edb4c82c400e06b5924a6f2b5d7',
    );
  });

  test('session token is sent and signed; Host is not returned', () {
    final headers = const SigV4Signer(region: 'eu-north-1').sign(
      method: 'POST',
      uri: Uri.parse(
        'https://tracking.geo.eu-north-1.amazonaws.com/tracking/v0/trackers/t/positions',
      ),
      credentials: const AwsCredentials(
        accessKeyId: 'AKID',
        secretAccessKey: 'secret',
        sessionToken: 'token',
      ),
      headers: {'Content-Type': 'application/json'},
      body: '{}'.codeUnits,
      now: now,
    );
    expect(headers['X-Amz-Security-Token'], 'token');
    expect(headers.keys.map((k) => k.toLowerCase()), isNot(contains('host')));
    expect(
      authorization(headers),
      contains(
        'SignedHeaders=content-type;host;x-amz-date;x-amz-security-token',
      ),
    );
    expect(authorization(headers), contains('/eu-north-1/geo/aws4_request'));
  });

  test('credentials expiry check', () {
    final c = AwsCredentials(
      accessKeyId: 'a',
      secretAccessKey: 'b',
      expiration: now.add(const Duration(minutes: 4)),
    );
    expect(c.expiresWithin(const Duration(minutes: 5), now), isTrue);
    expect(c.expiresWithin(const Duration(minutes: 3), now), isFalse);
  });
}
