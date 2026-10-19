import '../../../../core/error/guard.dart';
import '../../../../core/result/result.dart';
import '../../../../platform/aws_location_platform.dart';
import '../../domain/entities/cloud_tracking.dart';
import '../../domain/repositories/cloud_tracking_repository.dart';
import '../datasources/device_location_data_source.dart';

class CloudTrackingRepositoryImpl implements CloudTrackingRepository {
  const CloudTrackingRepositoryImpl(this._platform, this._location);

  final AwsLocationPlatform _platform;

  /// Used to ask for location permission before tracking starts; the SDKs
  /// expect the app to have it.
  final DeviceLocationDataSource _location;

  @override
  Stream<CloudTrackingEvent> get events => _platform.trackingEvents;

  @override
  Future<Result<String>> configure(CloudTrackerConfig config) =>
      guard(() => _platform.configureTracker(config));

  @override
  Future<Result<void>> start() => guard(() async {
    await _location.ensurePermission();
    await _platform.startTracking();
  });

  @override
  Future<Result<void>> stop() => guard(_platform.stopTracking);

  @override
  Future<Result<void>> startBackground(BackgroundTrackingMode mode) =>
      guard(() async {
        await _location.ensurePermission();
        await _platform.startBackgroundTracking(mode);
      });

  @override
  Future<Result<void>> stopBackground() =>
      guard(_platform.stopBackgroundTracking);

  @override
  Future<Result<bool>> isTracking() => guard(_platform.isTracking);

  @override
  Future<Result<TrackerPosition?>> latestPosition() =>
      guard(_platform.latestPosition);

  @override
  Future<Result<List<TrackerPosition>>> positionHistory({
    DateTime? from,
    DateTime? to,
    int? maxResults,
  }) => guard(
    () => _platform.positionHistory(from: from, to: to, maxResults: maxResults),
  );
}
