import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../features/tracking/domain/entities/cloud_tracking.dart';
import 'method_channel_aws_location.dart';

/// The platform-specific part of the plugin: cloud tracking.
///
/// * Android and iOS: [MethodChannelAwsLocation], backed by the Amazon
///   Location Mobile Auth and Tracking SDKs.
/// * Web: `AwsLocationWeb`, a Dart implementation of the same calls
///   (Cognito + SigV4 + browser geolocation).
///
/// Methods throw the plugin's data-layer exceptions (`TrackingException`,
/// `LocationPermissionException`, `ServerException`, `NetworkException`);
/// `CloudTrackingRepositoryImpl` turns them into failures.
abstract class AwsLocationPlatform extends PlatformInterface {
  AwsLocationPlatform() : super(token: _token);

  static final Object _token = Object();

  static AwsLocationPlatform _instance = MethodChannelAwsLocation();

  /// The implementation in use; defaults to [MethodChannelAwsLocation].
  static AwsLocationPlatform get instance => _instance;

  /// Set by the web implementation, or by tests with a fake.
  static set instance(AwsLocationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Positions, uploads and errors while tracking runs (broadcast).
  Stream<CloudTrackingEvent> get trackingEvents;

  /// Signs in to the identity pool and creates the tracker client. Returns
  /// the device id positions are reported under.
  Future<String> configureTracker(CloudTrackerConfig config);

  Future<void> startTracking();

  Future<void> stopTracking();

  Future<void> startBackgroundTracking(BackgroundTrackingMode mode);

  Future<void> stopBackgroundTracking();

  Future<bool> isTracking();

  Future<TrackerPosition?> latestPosition();

  Future<List<TrackerPosition>> positionHistory({
    DateTime? from,
    DateTime? to,
    int? maxResults,
  });
}
