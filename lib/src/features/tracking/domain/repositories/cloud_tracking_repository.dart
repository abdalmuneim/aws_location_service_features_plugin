import '../../../../core/result/result.dart';
import '../entities/cloud_tracking.dart';

/// Sends device positions to an Amazon Location tracker and reads them
/// back. Backed by the Amazon Location Mobile Tracking SDKs on Android and
/// iOS, and by a Dart implementation on the web.
abstract interface class CloudTrackingRepository {
  /// Positions received, uploads and errors while tracking runs.
  Stream<CloudTrackingEvent> get events;

  /// Signs in to the identity pool and prepares the tracker. Returns the id
  /// this device reports positions under.
  Future<Result<String>> configure(CloudTrackerConfig config);

  /// Foreground tracking (asks for location permission when needed).
  Future<Result<void>> start();

  Future<Result<void>> stop();

  /// Keeps tracking while the app is in the background (Android, iOS).
  Future<Result<void>> startBackground(BackgroundTrackingMode mode);

  Future<Result<void>> stopBackground();

  Future<Result<bool>> isTracking();

  /// The device's latest position stored by the tracker, or null before
  /// the first upload.
  Future<Result<TrackerPosition?>> latestPosition();

  /// Positions stored by the tracker for this device (the tracker keeps 30
  /// days), oldest first.
  Future<Result<List<TrackerPosition>>> positionHistory({
    DateTime? from,
    DateTime? to,
    int? maxResults,
  });
}
