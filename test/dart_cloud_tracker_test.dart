import 'dart:async';
import 'dart:convert';

import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _poolId = 'eu-north-1:11111111-2222-3333-4444-555555555555';
const _tracker = 'studio';

/// A fake AWS: Cognito Identity plus the tracker endpoints.
class _FakeAws {
  int getIdCalls = 0;
  final uploads = <List<Map<String, dynamic>>>[];
  final uploadHeaders = <Map<String, String>>[];
  int failUploads = 0;
  bool hasLatest = false;
  final List<Map<String, dynamic>> stored = [];

  late final client = MockClient((request) async {
    final host = request.url.host;
    if (host == 'cognito-identity.eu-north-1.amazonaws.com') {
      final target = request.headers['X-Amz-Target'];
      if (target == 'AWSCognitoIdentityService.GetId') {
        getIdCalls++;
        return _json({'IdentityId': 'eu-north-1:identity'});
      }
      if (target == 'AWSCognitoIdentityService.GetCredentialsForIdentity') {
        final expiry = DateTime.now().add(const Duration(hours: 1));
        return _json({
          'IdentityId': 'eu-north-1:identity',
          'Credentials': {
            'AccessKeyId': 'AKID',
            'SecretKey': 'secret',
            'SessionToken': 'token',
            'Expiration': expiry.millisecondsSinceEpoch / 1000,
          },
        });
      }
    }
    if (host == 'tracking.geo.eu-north-1.amazonaws.com') {
      final path = request.url.path;
      if (path == '/tracking/v0/trackers/$_tracker/positions') {
        uploadHeaders.add(request.headers);
        if (failUploads > 0) {
          failUploads--;
          return _json({'message': 'Service unavailable'}, 503);
        }
        final updates = (jsonDecode(request.body)['Updates'] as List)
            .cast<Map<String, dynamic>>();
        uploads.add(updates);
        stored.addAll(updates);
        return _json({'Errors': <Object>[]});
      }
      if (path.endsWith('/positions/latest')) {
        if (!hasLatest) return _json({'message': 'Not found'}, 404);
        return _json({
          'DeviceId': 'd',
          'Position': [31.0, 30.0],
          'SampleTime': '2026-10-19T10:00:00Z',
          'ReceivedTime': '2026-10-19T10:00:01Z',
          'Accuracy': {'Horizontal': 4.5},
        });
      }
      if (path.endsWith('/list-positions')) {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final page = body['NextToken'] == null ? 0 : 1;
        return _json({
          'DevicePositions': [
            for (var i = 0; i < 2; i++)
              {
                'Position': [31.0 + page, 30.0 + i],
                'SampleTime': '2026-10-19T10:0$page:0${i}Z',
              },
          ],
          if (page == 0) 'NextToken': 'next',
        });
      }
    }
    return http.Response('unexpected ${request.method} ${request.url}', 500);
  });

  static http.Response _json(Object body, [int status = 200]) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );
}

class _FakeLocation implements DeviceLocationDataSource {
  final controller = StreamController<DevicePosition>.broadcast();

  @override
  Future<void> ensurePermission() async {}

  @override
  Future<DevicePosition> current() => throw UnimplementedError();

  @override
  Stream<DevicePosition> watch(int distanceFilterMeters) => controller.stream;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAws aws;
  late _FakeLocation location;
  late DartCloudTracker tracker;
  late List<CloudTrackingEvent> events;
  final t0 = DateTime.utc(2026, 10, 19, 10);
  const origin = GeoPoint(30.0444, 31.2357);

  DevicePosition at(Duration after, double metersNorth) => DevicePosition(
    point: GeoUtils.offset(origin, metersNorth, 0),
    timestamp: t0.add(after),
    accuracyMeters: 5,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    aws = _FakeAws();
    location = _FakeLocation();
    tracker = DartCloudTracker(httpClient: aws.client, location: location);
    events = [];
    tracker.trackingEvents.listen(events.add);
  });

  Future<String> configure() => tracker.configureTracker(
    const CloudTrackerConfig(identityPoolId: _poolId, trackerName: _tracker),
  );

  test('configure signs in and keeps one device id', () async {
    final id = await configure();
    expect(id, matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(await configure(), id);
    // The Cognito identity is reused too.
    expect(aws.getIdCalls, 1);
  });

  test('calls before configure fail with trackerNotConfigured', () async {
    expect(
      tracker.startTracking,
      throwsA(
        isA<TrackingException>().having(
          (e) => e.code,
          'code',
          FailureCode.trackerNotConfigured,
        ),
      ),
    );
  });

  test('filters, uploads signed batches and reports events', () async {
    final deviceId = await configure();
    await tracker.startTracking();
    expect(await tracker.isTracking(), isTrue);

    location.controller
      ..add(at(Duration.zero, 0))
      // 10 s and 5 m later: dropped by the time and distance filters.
      ..add(at(const Duration(seconds: 10), 5))
      // 40 s and 100 m later: accepted.
      ..add(at(const Duration(seconds: 40), 100));
    await pumpEventQueue();

    expect(aws.uploads, hasLength(2));
    final first = aws.uploads.first.single;
    expect(first['DeviceId'], deviceId);
    expect(first['SampleTime'], '2026-10-19T10:00:00.000Z');
    expect(first['Accuracy'], {'Horizontal': 5.0});
    final auth = aws.uploadHeaders.first['Authorization']!;
    expect(auth, startsWith('AWS4-HMAC-SHA256 Credential=AKID/'));
    expect(auth, contains('/eu-north-1/geo/aws4_request'));
    expect(aws.uploadHeaders.first['X-Amz-Security-Token'], 'token');

    expect(events.whereType<TrackingPositionReceived>(), hasLength(3));
    expect(events.whereType<TrackingUploadSkipped>(), hasLength(1));
    expect(events.whereType<TrackingUploaded>(), hasLength(2));

    await tracker.stopTracking();
    expect(await tracker.isTracking(), isFalse);
  });

  test('failed uploads stay queued and go out with the next one', () async {
    await configure();
    await tracker.startTracking();
    aws.failUploads = 1;
    location.controller.add(at(Duration.zero, 0));
    await pumpEventQueue();
    expect(
      events.whereType<TrackingErrorEvent>().single.message,
      contains('503'),
    );
    expect(tracker.queued, hasLength(1));

    location.controller.add(at(const Duration(minutes: 1), 200));
    await pumpEventQueue();
    expect(tracker.queued, isEmpty);
    expect(aws.uploads.single, hasLength(2));
  });

  test('latest position is null until the tracker has one', () async {
    await configure();
    expect(await tracker.latestPosition(), isNull);
    aws.hasLatest = true;
    final latest = await tracker.latestPosition();
    expect(latest!.point, const GeoPoint(30, 31));
    expect(latest.accuracyMeters, 4.5);
    expect(latest.receivedTime, DateTime.utc(2026, 10, 19, 10, 0, 1));
  });

  test('history follows NextToken', () async {
    await configure();
    final all = await tracker.positionHistory();
    expect(all, hasLength(4));
    final capped = await tracker.positionHistory(maxResults: 2);
    expect(capped, hasLength(2));
  });

  test('background tracking is unsupported', () async {
    await configure();
    expect(
      () => tracker.startBackgroundTracking(BackgroundTrackingMode.active),
      throwsA(
        isA<TrackingException>().having(
          (e) => e.code,
          'code',
          FailureCode.backgroundTrackingUnsupported,
        ),
      ),
    );
  });

  group('filters', () {
    const config = CloudTrackerConfig(
      identityPoolId: _poolId,
      trackerName: _tracker,
      minTimeBetweenUploads: Duration(seconds: 30),
      minDistanceMeters: 30,
      accuracyFilter: true,
    );
    TrackerPosition p(int seconds, double meters, [double? accuracy]) =>
        TrackerPosition(
          point: GeoUtils.offset(origin, meters, 0),
          sampleTime: t0.add(Duration(seconds: seconds)),
          accuracyMeters: accuracy,
        );

    test('first position always passes', () {
      expect(DartCloudTracker.passesFilters(config, p(0, 0), null), isTrue);
    });

    test('each filter can drop a position', () {
      final prev = p(0, 0);
      expect(DartCloudTracker.passesFilters(config, p(20, 100), prev), isFalse);
      expect(DartCloudTracker.passesFilters(config, p(60, 10), prev), isFalse);
      expect(
        DartCloudTracker.passesFilters(config, p(60, 40, 50), prev),
        isFalse,
      );
      expect(
        DartCloudTracker.passesFilters(config, p(60, 40, 10), prev),
        isTrue,
      );
    });

    test('disabled filters let everything through', () {
      final open = config.copyWith(
        clearTimeFilter: true,
        clearDistanceFilter: true,
        accuracyFilter: false,
      );
      expect(DartCloudTracker.passesFilters(open, p(1, 1), p(0, 0)), isTrue);
    });
  });
}
