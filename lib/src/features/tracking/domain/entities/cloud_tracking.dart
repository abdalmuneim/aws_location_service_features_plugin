import 'package:equatable/equatable.dart';

import '../../../../core/entities/geo_point.dart';

/// How positions keep flowing when the app is in the background.
enum BackgroundTrackingMode {
  /// Continuous updates. Android runs a foreground service with a
  /// notification; iOS keeps location updates running.
  active,

  /// Fewer updates to save battery. Android uploads about every 15 minutes
  /// (WorkManager); iOS lets the system pause updates.
  batterySaver,
}

/// The ongoing notification Android shows while background tracking runs.
class TrackingNotification extends Equatable {
  const TrackingNotification({
    this.title = 'Tracking your location',
    this.description = 'Your location is being shared with Amazon Location.',
    this.channelName = 'Location tracking',
    this.iconName,
  });

  final String title;
  final String description;

  /// Name of the Android notification channel, shown in system settings.
  final String channelName;

  /// Name of a drawable resource in the host app (e.g. `ic_tracking`), or
  /// null for the SDK's default icon.
  final String? iconName;

  Map<String, Object?> toMap() => {
    'title': title,
    'description': description,
    'channelName': channelName,
    'iconName': iconName,
  };

  @override
  List<Object?> get props => [title, description, channelName, iconName];
}

/// Settings for sending device positions to an Amazon Location tracker.
///
/// Trackers do not accept API keys: positions are signed with temporary
/// credentials from an Amazon Cognito identity pool whose unauthenticated
/// role allows `geo:BatchUpdateDevicePosition` (plus
/// `geo:GetDevicePosition` and `geo:GetDevicePositionHistory` to read
/// positions back) on the tracker.
class CloudTrackerConfig extends Equatable {
  const CloudTrackerConfig({
    required this.identityPoolId,
    required this.trackerName,
    this.minTimeBetweenUploads = const Duration(seconds: 30),
    this.minDistanceMeters = 30,
    this.accuracyFilter = false,
    this.notification = const TrackingNotification(),
  });

  /// Cognito identity pool id, e.g. `eu-north-1:1234abcd-...`. Its region
  /// is also the tracker's region.
  final String identityPoolId;

  /// Name of the Amazon Location tracker resource.
  final String trackerName;

  /// Skip positions sampled sooner than this after the last uploaded one;
  /// null disables the time filter.
  final Duration? minTimeBetweenUploads;

  /// Skip positions closer than this to the last uploaded one; null
  /// disables the distance filter.
  final double? minDistanceMeters;

  /// Skip positions whose movement is within their own accuracy radius.
  final bool accuracyFilter;

  /// Android only.
  final TrackingNotification notification;

  /// The region embedded in [identityPoolId].
  String get region => identityPoolId.split(':').first;

  CloudTrackerConfig copyWith({
    String? identityPoolId,
    String? trackerName,
    Duration? minTimeBetweenUploads,
    bool clearTimeFilter = false,
    double? minDistanceMeters,
    bool clearDistanceFilter = false,
    bool? accuracyFilter,
    TrackingNotification? notification,
  }) => CloudTrackerConfig(
    identityPoolId: identityPoolId ?? this.identityPoolId,
    trackerName: trackerName ?? this.trackerName,
    minTimeBetweenUploads: clearTimeFilter
        ? null
        : minTimeBetweenUploads ?? this.minTimeBetweenUploads,
    minDistanceMeters: clearDistanceFilter
        ? null
        : minDistanceMeters ?? this.minDistanceMeters,
    accuracyFilter: accuracyFilter ?? this.accuracyFilter,
    notification: notification ?? this.notification,
  );

  @override
  List<Object?> get props => [
    identityPoolId,
    trackerName,
    minTimeBetweenUploads,
    minDistanceMeters,
    accuracyFilter,
    notification,
  ];
}

/// A device position stored in (or bound for) an Amazon Location tracker.
class TrackerPosition extends Equatable {
  const TrackerPosition({
    required this.point,
    required this.sampleTime,
    this.deviceId,
    this.receivedTime,
    this.accuracyMeters,
  });

  final GeoPoint point;

  /// When the device sampled the position.
  final DateTime sampleTime;
  final String? deviceId;

  /// When Amazon Location stored it (positions read back from the tracker).
  final DateTime? receivedTime;
  final double? accuracyMeters;

  @override
  List<Object?> get props => [
    point,
    sampleTime,
    deviceId,
    receivedTime,
    accuracyMeters,
  ];
}

/// Something that happened while cloud tracking runs.
sealed class CloudTrackingEvent extends Equatable {
  const CloudTrackingEvent(this.time);

  final DateTime time;
}

/// The SDK received a position from the device.
final class TrackingPositionReceived extends CloudTrackingEvent {
  const TrackingPositionReceived(super.time, this.position);

  final TrackerPosition position;

  @override
  List<Object?> get props => [time, position];
}

/// A batch is being sent to the tracker.
final class TrackingUploadStarted extends CloudTrackingEvent {
  const TrackingUploadStarted(super.time, this.positions);

  final List<TrackerPosition> positions;

  @override
  List<Object?> get props => [time, positions];
}

/// A batch was stored by the tracker.
final class TrackingUploaded extends CloudTrackingEvent {
  const TrackingUploaded(super.time, this.positions);

  final List<TrackerPosition> positions;

  @override
  List<Object?> get props => [time, positions];
}

/// A position was dropped by the time, distance or accuracy filter.
final class TrackingUploadSkipped extends CloudTrackingEvent {
  const TrackingUploadSkipped(super.time, this.position);

  final TrackerPosition position;

  @override
  List<Object?> get props => [time, position];
}

/// Location became available or unavailable (Android).
final class TrackingAvailabilityChanged extends CloudTrackingEvent {
  const TrackingAvailabilityChanged(super.time, {required this.available});

  final bool available;

  @override
  List<Object?> get props => [time, available];
}

/// Background tracking stopped, e.g. from the notification's Stop action.
final class TrackingBackgroundStopped extends CloudTrackingEvent {
  const TrackingBackgroundStopped(super.time);

  @override
  List<Object?> get props => [time];
}

/// An upload or credentials refresh failed. Positions stay queued and are
/// retried with the next update.
final class TrackingErrorEvent extends CloudTrackingEvent {
  const TrackingErrorEvent(super.time, this.message);

  final String message;

  @override
  List<Object?> get props => [time, message];
}
