import 'dart:async';

import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:aws_location_service_features/aws_location_service_features_platform_interface.dart';
import 'package:aws_location_service_features_example/core/presentation/load_status.dart';
import 'package:aws_location_service_features_example/features/cloud_tracking/domain/repositories/cloud_tracker_settings_repository.dart';
import 'package:aws_location_service_features_example/features/cloud_tracking/domain/usecases/cloud_tracker_settings_usecases.dart';
import 'package:aws_location_service_features_example/features/cloud_tracking/presentation/cubit/cloud_tracking_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlatform extends AwsLocationPlatform {
  final events = StreamController<CloudTrackingEvent>.broadcast();
  bool tracking = false;
  Object? startError;

  @override
  Stream<CloudTrackingEvent> get trackingEvents => events.stream;

  @override
  Future<String> configureTracker(CloudTrackerConfig config) async =>
      'device-42';

  @override
  Future<void> startTracking() async {
    if (startError != null) throw startError!;
    tracking = true;
  }

  @override
  Future<void> stopTracking() async => tracking = false;

  @override
  Future<void> startBackgroundTracking(BackgroundTrackingMode mode) async {}

  @override
  Future<void> stopBackgroundTracking() async {}

  @override
  Future<bool> isTracking() async => tracking;

  @override
  Future<TrackerPosition?> latestPosition() async => null;

  @override
  Future<List<TrackerPosition>> positionHistory({
    DateTime? from,
    DateTime? to,
    int? maxResults,
  }) async => const [];
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

class _MemorySettings implements CloudTrackerSettingsRepository {
  CloudTrackerConfig saved = const CloudTrackerConfig(
    identityPoolId: 'eu-north-1:00000000-0000-4000-8000-000000000000',
    trackerName: 'studio',
  );

  @override
  Future<Result<CloudTrackerConfig>> load() async => Ok(saved);

  @override
  Future<Result<CloudTrackerConfig>> save(CloudTrackerConfig config) async =>
      Ok(saved = config);
}

void main() {
  late _FakePlatform platform;
  late _MemorySettings settings;
  late CloudTrackingCubit cubit;

  setUp(() async {
    platform = _FakePlatform();
    settings = _MemorySettings();
    final repo = CloudTrackingRepositoryImpl(platform, _AllowedLocation());
    cubit = CloudTrackingCubit(
      LoadCloudTrackerSettings(settings),
      SaveCloudTrackerSettings(settings),
      ConfigureCloudTracker(repo),
      StartCloudTracking(repo),
      StopCloudTracking(repo),
      StartBackgroundTracking(repo),
      StopBackgroundTracking(repo),
      GetTrackerPosition(repo),
      GetTrackerHistory(repo),
      WatchCloudTracking(repo),
    );
    await cubit.init();
  });

  tearDown(() => cubit.close());

  TrackerPosition at(double lat) =>
      TrackerPosition(point: GeoPoint(lat, 31), sampleTime: DateTime.utc(2026));

  test('loads the saved settings', () {
    expect(cubit.state.config.trackerName, 'studio');
    expect(cubit.state.connected, isFalse);
  });

  test('connect saves the settings and shows the device id', () async {
    cubit.updateConfig(cubit.state.config.copyWith(trackerName: 'fleet'));
    await cubit.connect();
    expect(cubit.state.deviceId, 'device-42');
    expect(settings.saved.trackerName, 'fleet');
  });

  test('invalid settings fail without reaching the platform', () async {
    cubit.updateConfig(cubit.state.config.copyWith(identityPoolId: 'nope'));
    await cubit.connect();
    expect(cubit.state.connected, isFalse);
    expect(cubit.state.failure?.code, FailureCode.identityPoolIdInvalid);
  });

  test('start and stop toggle tracking', () async {
    await cubit.connect();
    await cubit.start();
    expect(cubit.state.tracking, isTrue);
    expect(platform.tracking, isTrue);
    await cubit.stop();
    expect(cubit.state.tracking, isFalse);
  });

  test('a platform error becomes a failure', () async {
    await cubit.connect();
    platform.startError = const TrackingException(
      'no',
      code: FailureCode.trackerNotConfigured,
    );
    await cubit.start();
    expect(cubit.state.tracking, isFalse);
    expect(cubit.state.status, LoadStatus.failure);
    expect(cubit.state.failure?.code, FailureCode.trackerNotConfigured);
  });

  test('events update the trail, counters and log', () async {
    final now = DateTime.now();
    platform.events
      ..add(TrackingPositionReceived(now, at(30)))
      ..add(TrackingPositionReceived(now, at(30.001)))
      ..add(TrackingUploaded(now, [at(30)]))
      ..add(TrackingUploadSkipped(now, at(30.001)))
      ..add(TrackingErrorEvent(now, 'offline'))
      ..add(TrackingBackgroundStopped(now));
    await pumpEventQueue();
    final s = cubit.state;
    expect(s.received, hasLength(2));
    expect(s.uploaded, hasLength(1));
    expect(s.skipped, 1);
    expect(s.errors, 1);
    expect(s.log.first, isA<TrackingBackgroundStopped>());
    expect(s.log, hasLength(6));

    cubit.clearSession();
    expect(cubit.state.received, isEmpty);
    expect(cubit.state.log, isEmpty);
  });
}
