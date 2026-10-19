import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:aws_location_service_features/aws_location_service_features_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelAwsLocation();
  final calls = <MethodCall>[];
  Object? Function(MethodCall call)? reply;

  setUp(() {
    calls.clear();
    reply = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.methodChannel, (call) async {
          calls.add(call);
          return reply?.call(call);
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.methodChannel, null);
  });

  test('is the default instance', () {
    expect(AwsLocationPlatform.instance, isA<MethodChannelAwsLocation>());
  });

  test('configure sends the settings and returns the device id', () async {
    reply = (_) => 'device-1';
    final id = await platform.configureTracker(
      const CloudTrackerConfig(
        identityPoolId: 'eu-north-1:00000000-0000-0000-0000-000000000000',
        trackerName: 'studio',
        minTimeBetweenUploads: Duration(seconds: 15),
        minDistanceMeters: null,
        accuracyFilter: true,
        notification: TrackingNotification(title: 'Tracking'),
      ),
    );
    expect(id, 'device-1');
    final call = calls.single;
    expect(call.method, 'configure');
    final args = call.arguments as Map;
    expect(args['region'], 'eu-north-1');
    expect(args['trackerName'], 'studio');
    expect(args['timeFilterMillis'], 15000);
    expect(args['distanceFilterMeters'], isNull);
    expect(args['accuracyFilter'], true);
    expect((args['notification'] as Map)['title'], 'Tracking');
  });

  test('background mode is sent by name', () async {
    await platform.startBackgroundTracking(BackgroundTrackingMode.batterySaver);
    expect(calls.single.method, 'startBackground');
    expect((calls.single.arguments as Map)['mode'], 'batterySaver');
  });

  test('positions are decoded', () async {
    reply = (call) => switch (call.method) {
      'latestPosition' => {
        'latitude': 30.0,
        'longitude': 31.0,
        'sampleTime': 1000,
        'receivedTime': 2000,
        'accuracy': 5.0,
        'deviceId': 'd',
      },
      'positionHistory' => [
        {'latitude': 1.0, 'longitude': 2.0, 'sampleTime': 0},
        {'latitude': 'bad'},
      ],
      _ => null,
    };
    final latest = await platform.latestPosition();
    expect(latest!.point, const GeoPoint(30, 31));
    expect(
      latest.sampleTime,
      DateTime.fromMillisecondsSinceEpoch(1000, isUtc: true),
    );
    expect(latest.accuracyMeters, 5);
    final history = await platform.positionHistory(maxResults: 10);
    expect(history, hasLength(1));
    expect((calls.last.arguments as Map)['maxResults'], 10);
  });

  test('native errors map to the plugin exceptions', () async {
    Future<Object> error(String code) async {
      reply = (_) => throw PlatformException(code: code, message: 'detail');
      try {
        await platform.startTracking();
      } catch (e) {
        return e;
      }
      fail('no error');
    }

    expect(
      await error('NOT_CONFIGURED'),
      isA<TrackingException>().having(
        (e) => e.code,
        'code',
        FailureCode.trackerNotConfigured,
      ),
    );
    expect(
      await error('PERMISSION_DENIED'),
      isA<LocationPermissionException>(),
    );
    expect(
      await error('ACCESS_DENIED'),
      isA<ServerException>()
          .having((e) => e.statusCode, 'status', 403)
          .having((e) => e.signed, 'signed', true),
    );
    expect(
      await error('AUTH_FAILED'),
      isA<TrackingException>().having(
        (e) => e.code,
        'code',
        FailureCode.cognitoSignInFailed,
      ),
    );
    expect(
      await error('SOMETHING_ELSE'),
      isA<TrackingException>().having(
        (e) => e.args['detail'],
        'detail',
        'detail',
      ),
    );
  });

  test('a failed call becomes a failure through the repository', () async {
    reply = (_) => throw PlatformException(code: 'UNSUPPORTED', message: 'no');
    final repo = CloudTrackingRepositoryImpl(platform, _AllowedLocation());
    final result = await repo.startBackground(BackgroundTrackingMode.active);
    expect(
      result.failureOrNull,
      isA<TrackingFailure>().having(
        (f) => f.code,
        'code',
        FailureCode.backgroundTrackingUnsupported,
      ),
    );
  });

  test('events are decoded', () {
    final events = [
      {
        'type': 'position',
        'time': 0,
        'position': {'latitude': 1.0, 'longitude': 2.0, 'sampleTime': 0},
      },
      {
        'type': 'uploaded',
        'time': 0,
        'positions': [
          {'latitude': 1.0, 'longitude': 2.0, 'sampleTime': 0},
        ],
      },
      {'type': 'availability', 'time': 0, 'available': false},
      {'type': 'backgroundStopped', 'time': 0},
      {'type': 'error', 'time': 0, 'message': 'boom'},
      {'type': 'unknown'},
    ].map(MethodChannelAwsLocation.decodeEvent).toList();
    expect(events[0], isA<TrackingPositionReceived>());
    expect((events[1]! as TrackingUploaded).positions, hasLength(1));
    expect((events[2]! as TrackingAvailabilityChanged).available, isFalse);
    expect(events[3], isA<TrackingBackgroundStopped>());
    expect((events[4]! as TrackingErrorEvent).message, 'boom');
    expect(events[5], isNull);
  });
}

class _AllowedLocation implements DeviceLocationDataSource {
  @override
  Future<void> ensurePermission() async {}

  @override
  Future<DevicePosition> current() => throw UnimplementedError();

  @override
  Stream<DevicePosition> watch(int distanceFilterMeters) =>
      const Stream.empty();
}
